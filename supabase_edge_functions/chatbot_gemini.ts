import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }

  try {
    console.log('Chatbot edge function called');
    const { plant_id, message, history, plant_info } = await req.json();
    
    console.log('Request data:', {
      plant_id,
      message,
      history: history?.length,
      plant_info
    });

    // Validate required fields
    if (!message) {
      return new Response(JSON.stringify({
        error: 'message is required'
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Missing environment variables:', {
        supabaseUrl: !!supabaseUrl,
        supabaseServiceKey: !!supabaseServiceKey
      });
      throw new Error('Missing required environment variables');
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get plant details
    let plantDetails = {};
    if (plant_id) {
      const { data: plantData, error: plantError } = await supabase
        .from('plants')
        .select('*')
        .eq('id', plant_id)
        .single();
      
      if (!plantError && plantData) {
        plantDetails = plantData;
      }
    }

    // Prepare context for Gemini
    let context = `You are a helpful plant care assistant. The user is a human asking for advice about their plants. 

Plant Information:
- Plant Name: ${plant_info?.name || plantDetails?.name || 'Unknown'}
- Plant Species: ${plant_info?.species || plantDetails?.species || 'Unknown'}
- Current Soil Moisture: ${plant_info?.current_moisture || 'Unknown'}%
- Current Light Level: ${plant_info?.current_light || 'Unknown'} lux

User Question: ${message}

Please provide helpful, practical advice about plant care. Be friendly and informative. Keep your response concise but helpful. 

IMPORTANT: If the user asks about specific care for their plant species, provide detailed advice based on the plant species (${plant_info?.species || plantDetails?.species || 'Unknown'}). Consider the specific needs, watering frequency, light requirements, and common issues for this type of plant.`;

    // Add sensor history if provided
    if (history && history.length > 0) {
      context += `\n\nSensor Data (Last 24 hours):
${history.map((h) => `- Time: ${h.recorded_at}, Moisture: ${h.humidity}%, Light: ${h.light} lux`).join('\n')}`;
    }

    // Call Gemini API
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
    
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY environment variable is required');
    }

    console.log('Calling Gemini API...');
    const geminiResponse = await fetch(`https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: context
              }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 500
        }
      })
    });

    console.log('Gemini API response status:', geminiResponse.status);
    
    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text();
      console.error('Gemini API error:', errorText);
      throw new Error(`Gemini API error: ${geminiResponse.status} - ${errorText}`);
    }

    const geminiData = await geminiResponse.json();
    console.log('Gemini API response received');
    
    const response = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || 'Sorry, I could not generate a response.';

    return new Response(JSON.stringify({
      response
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (error) {
    console.error('Chatbot error:', error);
    return new Response(JSON.stringify({
      error: error instanceof Error ? error.message : String(error)
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
