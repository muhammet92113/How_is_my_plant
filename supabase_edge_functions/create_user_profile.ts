import { createClient } from 'npm:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  // Validate request
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', {
      status: 405
    });
  }

  try {
    // Create Supabase client with service role key
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!, 
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Extract user ID from request
    const { user_id } = await req.json();

    if (!user_id) {
      return new Response(JSON.stringify({
        error: 'user_id is required'
      }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    // Insert user profile with empty FCM token
    const { data, error } = await supabase
      .from('user_profiles')
      .upsert({
        id: user_id,
        fcm_token: null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      })
      .select();

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
