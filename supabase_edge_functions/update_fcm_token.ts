import { createClient } from 'npm:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', {
      status: 405
    });
  }

  try {
    // Supabase client with service role key
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!, 
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Extract data from request
    const { user_id, fcm_token } = await req.json();
    
    if (!user_id || !fcm_token) {
      return new Response(JSON.stringify({
        error: 'Missing user_id or fcm_token'
      }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    // Update FCM token in user_profiles table
    const { data, error } = await supabase
      .from('user_profiles')
      .update({
        fcm_token,
        updated_at: new Date().toISOString()
      })
      .eq('id', user_id)
      .select();

    if (error) {
      throw error;
    }

    return new Response(JSON.stringify({
      message: 'FCM token updated',
      data
    }), {
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
