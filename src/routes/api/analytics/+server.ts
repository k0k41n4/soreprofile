import { json } from '@sveltejs/kit';
import { supabase } from '$lib/supabase';

export async function POST({ request }) {
  const { profileId, linkId } = await request.json();
  const userAgent = request.headers.get('user-agent');

  const { error } = await supabase
    .from('analytics')
    .insert([{
      profile_id: profileId,
      link_id: linkId,
      user_agent: userAgent,
      event_type: 'click'
    }]);

  if (error) {
    return json({ error: error.message }, { status: 500 });
  }

  return json({ success: true });
}
