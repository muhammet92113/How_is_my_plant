import { createClient } from 'npm:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  // Validate request
  if (req.method !== 'GET') {
    return new Response('Method Not Allowed', {
      status: 405
    });
  }

  try {
    // Create Supabase client with user's authorization
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!, 
      Deno.env.get('SUPABASE_ANON_KEY')!, 
      {
        global: {
          headers: {
            Authorization: req.headers.get('Authorization')!
          }
        }
      }
    );

    // Fetch user's plants with their latest sensor data
    const { data, error } = await supabase
      .from('plants')
      .select(`
        id,
        name,
        species,
        description,
        created_at,
        sensor_data (
          humidity,
          light,
          recorded_at
        )
      `)
      .order('sensor_data.recorded_at', {
        foreignTable: 'sensor_data',
        ascending: false
      })
      .limit(1, {
        foreignTable: 'sensor_data'
      });

    if (error) throw error;

    return new Response(JSON.stringify(data), {
      headers: {
        'Content-Type': 'application/json'
      }
    });
  } catch (err) {
    return new Response(JSON.stringify({
      error: err instanceof Error ? err.message : String(err)
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json'
      }
    });
  }
});
