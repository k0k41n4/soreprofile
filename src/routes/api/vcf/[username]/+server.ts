import { error } from '@sveltejs/kit';
import { supabase } from '$lib/supabase';

export async function GET({ params }) {
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('username', params.username)
    .single();

  if (!profile) throw error(404, 'Profile not found');

  const vCard = [
    'BEGIN:VCARD',
    'VERSION:3.0',
    `FN:${profile.display_name}`,
    `NOTE:${profile.bio || ''}`,
    ...profile.links.map((l: any) => `URL:${l.url}`),
    'END:VCARD'
  ].join('\n');

  return new Response(vCard, {
    headers: {
      'Content-Type': 'text/vcard',
      'Content-Disposition': `attachment; filename="${profile.username}.vcf"`
    }
  });
}
