<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabase';
  import { ExternalLink, Share2, ArrowRight, UserPlus, QrCode } from 'lucide-svelte';
  import QRCode from 'qrcode';

  let { data } = $props();
  let profile = $state<any>(null);
  let loading = $state(true);
  let error = $state<string | null>(null);
  let qrCodeDataUrl = $state<string>('');
  let showQr = $state(false);

  onMount(async () => {
    const { data: profileData, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('username', data.username)
      .single();

    if (profileError) {
      error = "Profile not found";
    } else {
      profile = profileData;
      // Generate QR Code
      qrCodeDataUrl = await QRCode.toDataURL(window.location.href, {
        margin: 2,
        color: {
          dark: profile.theme?.accent_color || '#00FFB2',
          light: '#00000000'
        }
      });
    }
    loading = false;
  });

  async function trackClick(linkId: string) {
    await fetch('/api/analytics', {
      method: 'POST',
      body: JSON.stringify({ profileId: profile.id, linkId })
    });
  }
</script>

<svelte:head>
  {#if profile}
    <title>{profile.seo?.title || `${profile.display_name} | Soreprofile`}</title>
    <meta name="description" content={profile.seo?.description || profile.bio} />
    <meta property="og:title" content={profile.seo?.title || profile.display_name} />
    <meta property="og:description" content={profile.seo?.description || profile.bio} />
    <meta property="og:image" content={profile.avatar_url} />
  {/if}
</svelte:head>

{#if loading}
  <div class="min-h-screen flex items-center justify-center bg-surface-900">
    <div class="w-12 h-12 border-4 border-brand-primary border-t-transparent rounded-full animate-spin"></div>
  </div>
{:else if error}
  <div class="min-h-screen flex flex-col items-center justify-center space-y-4 bg-surface-900">
    <h1 class="text-4xl font-bold">404</h1>
    <p class="text-gray-400">{error}</p>
    <a href="/" class="btn-primary">Go Home</a>
  </div>
{:else if profile}
  <div class="min-h-screen pb-20 transition-colors duration-500" style="background-color: {profile.theme?.bg_value || '#0A0A0A'}; color: {profile.theme?.text_color || '#FFFFFF'}">
    <div class="max-w-xl mx-auto px-6 pt-20 flex flex-col items-center text-center space-y-8">
      
      <!-- Action Buttons -->
      <div class="w-full flex justify-end gap-2 -mb-16">
        <button onclick={() => showQr = true} class="p-3 glass rounded-full hover:scale-110 transition-all border-white/5">
          <QrCode size={20} />
        </button>
        <a href="/api/vcf/{profile.username}" class="p-3 glass rounded-full hover:scale-110 transition-all border-white/5">
          <UserPlus size={20} />
        </a>
      </div>

      <!-- Avatar -->
      <div class="relative group">
        <div class="absolute inset-0 blur-2xl opacity-20 rounded-full" style="background-color: {profile.theme?.accent_color || '#00FFB2'}"></div>
        <img 
          src={profile.avatar_url || `https://ui-avatars.com/api/?name=${profile.display_name || profile.username}&background=${(profile.theme?.accent_color || '#00FFB2').replace('#', '')}&color=000`} 
          alt={profile.display_name} 
          class="w-32 h-32 rounded-full border-4 object-cover relative z-10"
          style="border-color: {profile.theme?.bg_value || '#121212'}"
        />
      </div>

      <div class="space-y-2">
        <h1 class="text-3xl font-bold tracking-tight">{profile.display_name || `@${profile.username}`}</h1>
        <p class="opacity-70 max-w-sm mx-auto">{profile.bio || 'No bio yet.'}</p>
      </div>

      <!-- Links -->
      <div class="w-full space-y-4">
        {#each profile.links || [] as link}
          <a 
            href={link.url} 
            target="_blank" 
            rel="noopener noreferrer"
            onclick={() => trackClick(link.id || link.title)}
            class="w-full p-4 rounded-2xl flex items-center justify-between group transition-all glass border-white/5 hover:bg-white/10"
          >
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center">
                 <ExternalLink size={18} class="opacity-50 group-hover:opacity-100 transition-opacity" style="color: {profile.theme?.accent_color}" />
              </div>
              <span class="font-semibold">{link.title}</span>
            </div>
            <ArrowRight size={18} class="opacity-20 group-hover:opacity-100 group-hover:translate-x-1 transition-all" style="color: {profile.theme?.accent_color}" />
          </a>
        {/each}
      </div>

      <!-- Footer -->
      <div class="pt-20">
        <a href="/" class="inline-flex items-center gap-2 opacity-40 hover:opacity-100 transition-opacity">
          <div class="w-5 h-5 rounded flex items-center justify-center text-[10px] font-bold" style="background-color: {profile.theme?.accent_color}; color: #000">S</div>
          Create your own Soreprofile
        </a>
      </div>
    </div>
  </div>

  <!-- QR Modal -->
  {#if showQr}
    <div class="fixed inset-0 z-50 flex items-center justify-center p-6 bg-black/80 backdrop-blur-sm" onclick={() => showQr = false}>
      <div class="glass p-8 rounded-[40px] max-w-sm w-full text-center space-y-6" onclick={e => e.stopPropagation()}>
        <h3 class="text-xl font-bold">Share Profile</h3>
        <img src={qrCodeDataUrl} alt="QR Code" class="w-full aspect-square rounded-2xl border-4 border-white/5 bg-white/5" />
        <p class="text-sm text-gray-400">Scan this code to view profile</p>
        <button onclick={() => showQr = false} class="w-full btn-primary py-3">Close</button>
      </div>
    </div>
  {/if}
{/if}

<style>
  .glass {
    background-color: rgba(255, 255, 255, 0.03);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.05);
  }
</style>
