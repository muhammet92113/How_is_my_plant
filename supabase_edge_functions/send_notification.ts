import { createClient } from 'npm:@supabase/supabase-js@2';
import { initializeApp, cert } from 'npm:firebase-admin/app';
import { getMessaging } from 'npm:firebase-admin/messaging';

// Firebase Admin SDK initialization
initializeApp({
  credential: cert({
    projectId: Deno.env.get('FIREBASE_PROJECT_ID'),
    clientEmail: Deno.env.get('FIREBASE_CLIENT_EMAIL'),
    privateKey: Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n')
  })
});

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', {
      status: 405
    });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!, 
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Extract data from request
    const { plant_id, message } = await req.json();
    
    if (!plant_id || !message) {
      return new Response(JSON.stringify({
        error: 'plant_id ve message zorunludur'
      }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    // Get user's FCM token through plant relationship
    const { data, error } = await supabase
      .from('plants')
      .select(`
        user_id,
        user_profiles!inner(fcm_token)
      `)
      .eq('id', plant_id)
      .single();

    if (error) throw error;

    const fcmToken = data.user_profiles?.fcm_token;
    
    if (!fcmToken) {
      return new Response(JSON.stringify({
        error: 'Kullanıcı için FCM token bulunamadı'
      }), {
        status: 404,
        headers: {
          'Content-Type': 'application/json'
        }
      });
    }

    // Send notification via Firebase Messaging
    const messaging = getMessaging();
    const response = await messaging.send({
      token: fcmToken,
      notification: {
        title: 'Bitki Sağlık Uyarısı',
        body: message
      },
      data: {
        plant_id: plant_id.toString(),
        type: 'health_alert'
      }
    });

    return new Response(JSON.stringify({
      message: 'Bildirim gönderildi',
      response
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
