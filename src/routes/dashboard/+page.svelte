<script lang="ts">
  import { onMount } from 'svelte';
  import { dndzone } from 'svelte-dnd-action';
  import { supabase } from '$lib/supabase';
  import { 
    GripVertical, 
    Plus, 
    Trash2, 
    Save, 
    ExternalLink, 
    User, 
    LogOut,
    Sparkles,
    Upload,
    Layout,
    ArrowRight,
    Palette,
    Search,
    BarChart3
  } from 'lucide-svelte';
  import { flip } from 'svelte/animate';

  let profile = $state<any>(null);
  let links = $state<any[]>([]);
  let analytics = $state<any[]>([]);
  let loading = $state(true);
  let saving = $state(false);
  let user = $state<any>(null);
  let activeTab = $state('profile');

  const flipDurationMs = 300;

  onMount(async () => {
    try {
      const { data: { session }, error: sessionError } = await supabase.auth.getSession();
      if (sessionError) throw sessionError;
      
      if (!session) {
        window.location.href = '/login';
        return;
      }
      user = session.user;

      const { data: profileData, error: fetchError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();

      if (profileData) {
        profile = profileData;
        links = profileData.links || [];
      } else {
        const { data: newProfile, error: insertError } = await supabase
          .from('profiles')
          .insert([{ 
            id: user.id, 
            username: user.email?.split('@')[0] || `user-${Math.random().toString(36).substr(2, 5)}`, 
            display_name: user.user_metadata.full_name || user.email?.split('@')[0] || 'User',
            links: [] 
          }])
          .select()
          .single();
        
        if (insertError) throw insertError;
        profile = newProfile;
        links = [];
      }

      // Fetch analytics
      const { data: analyticsData } = await supabase
        .from('analytics')
        .select('*')
        .eq('profile_id', user.id);
      analytics = analyticsData || [];

    } catch (err: any) {
      console.error('Dashboard Load Error:', err);
      alert('Error loading dashboard: ' + err.message);
    } finally {
      loading = false;
    }
  });

  function handleDndConsider(e: any) {
    links = e.detail.items;
  }

  function handleDndFinalize(e: any) {
    links = e.detail.items;
  }

  function addLink() {
    links = [...links, { id: Math.random().toString(36).substr(2, 9), title: 'New Link', url: 'https://' }];
  }

  function removeLink(id: string) {
    links = links.filter(l => l.id !== id);
  }

  async function saveProfile() {
    saving = true;
    const { error } = await supabase
      .from('profiles')
      .update({
        display_name: profile.display_name,
        bio: profile.bio,
        links: links,
        avatar_url: profile.avatar_url,
        theme: profile.theme,
        seo: profile.seo
      })
      .eq('id', user.id);

    if (error) {
      alert(error.message);
    } else {
      alert('Profile saved!');
    }
    saving = false;
  }

  async function handleAvatarUpload(e: any) {
    const file = e.target.files[0];
    if (!file) return;
    const fileExt = file.name.split('.').pop();
    const fileName = `${user.id}-${Math.random()}.${fileExt}`;
    const filePath = `avatars/${fileName}`;

    const { error: uploadError } = await supabase.storage
      .from('profiles')
      .upload(filePath, file);

    if (uploadError) {
      alert(uploadError.message);
      return;
    }

    const { data: { publicUrl } } = supabase.storage
      .from('profiles')
      .getPublicUrl(filePath);

    profile.avatar_url = publicUrl;
  }

  async function upgradeToPro() {
    const res = await fetch('/api/pay', {
      method: 'POST',
      body: JSON.stringify({ userId: user.id, plan: 'pro' })
    });
    const data = await res.json();
    if (data.redirect_url) {
      window.open(data.redirect_url, '_blank');
    }
  }

  async function logout() {
    await supabase.auth.signOut();
    window.location.href = '/';
  }

  const themes = [
    { name: 'Sore Dark', bg: '#0A0A0A', accent: '#00FFB2', text: '#FFFFFF' },
    { name: 'Neon Purple', bg: '#0F051D', accent: '#7000FF', text: '#FFFFFF' },
    { name: 'Soft Mint', bg: '#F0F9F4', accent: '#00A86B', text: '#1A1A1A' },
    { name: 'Sunset', bg: '#1A0B0B', accent: '#FF4D4D', text: '#FFFFFF' }
  ];

  function selectTheme(t: any) {
    profile.theme = { 
      ...profile.theme, 
      bg_value: t.bg, 
      accent_color: t.accent, 
      text_color: t.text 
    };
  }
</script>

<div class="min-h-screen flex flex-col md:flex-row">
  <!-- Sidebar -->
  <aside class="w-full md:w-80 border-r border-white/5 p-8 space-y-8 flex flex-col bg-surface-900 z-20">
    <div class="flex items-center gap-2">
      <div class="w-8 h-8 bg-brand-primary rounded-lg rotate-12 flex items-center justify-center">
        <span class="text-black font-bold -rotate-12">S</span>
      </div>
      <span class="text-xl font-bold tracking-tighter uppercase">Soreprofile</span>
    </div>

    <nav class="flex-1 space-y-1">
      <button 
        onclick={() => activeTab = 'profile'} 
        class="w-full flex items-center gap-3 p-3 rounded-xl transition-all {activeTab === 'profile' ? 'bg-white/10 text-white' : 'text-gray-500 hover:bg-white/5'}"
      >
        <User size={20} />
        Profile & Links
      </button>
      <button 
        onclick={() => activeTab = 'appearance'} 
        class="w-full flex items-center gap-3 p-3 rounded-xl transition-all {activeTab === 'appearance' ? 'bg-white/10 text-white' : 'text-gray-500 hover:bg-white/5'}"
      >
        <Palette size={20} />
        Appearance
      </button>
      <button 
        onclick={() => activeTab = 'seo'} 
        class="w-full flex items-center gap-3 p-3 rounded-xl transition-all {activeTab === 'seo' ? 'bg-white/10 text-white' : 'text-gray-500 hover:bg-white/5'}"
      >
        <Search size={20} />
        SEO & Social
      </button>
      <button 
        onclick={() => activeTab = 'analytics'} 
        class="w-full flex items-center gap-3 p-3 rounded-xl transition-all {activeTab === 'analytics' ? 'bg-white/10 text-white' : 'text-gray-500 hover:bg-white/5'}"
      >
        <BarChart3 size={20} />
        Analytics
      </button>
      
      <div class="pt-4 border-t border-white/5 mt-4">
        <button onclick={logout} class="w-full flex items-center gap-3 p-3 rounded-xl text-gray-500 hover:bg-white/5 transition-colors">
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </nav>

    <div class="p-6 glass rounded-2xl space-y-4">
      <div class="flex items-center gap-2 text-brand-primary text-xs font-bold uppercase tracking-widest">
        <Sparkles size={12} />
        Pro Plan
      </div>
      <p class="text-sm text-gray-400 leading-relaxed text-xs">Unlock custom themes and deep analytics.</p>
      <button onclick={upgradeToPro} class="w-full btn-primary py-2 text-xs">Upgrade Now</button>
    </div>

    <div class="p-6 glass rounded-2xl space-y-2">
      <p class="text-[10px] text-gray-500 uppercase font-bold tracking-widest">Public URL</p>
      <a 
        href={profile ? `/${profile.username}` : '#'} 
        target="_blank"
        class="text-brand-primary font-bold text-sm flex items-center justify-between group"
      >
        /{profile?.username || '...'}
        <ExternalLink size={14} class="group-hover:translate-x-1 transition-transform" />
      </a>
    </div>
  </aside>

  <!-- Main Content -->
  <main class="flex-1 p-8 md:p-16 max-w-4xl mx-auto w-full">
    {#if loading}
      <div class="flex items-center justify-center h-full">
        <div class="w-12 h-12 border-4 border-brand-primary border-t-transparent rounded-full animate-spin"></div>
      </div>
    {:else}
      <div class="space-y-12">
        <div class="flex justify-between items-end">
          <div>
            <h1 class="text-4xl font-bold tracking-tight capitalize">{activeTab}</h1>
            <p class="text-gray-400 mt-2">Personalize your digital presence</p>
          </div>
          <button onclick={saveProfile} disabled={saving} class="btn-primary">
            <Save size={20} />
            {saving ? 'Saving...' : 'Save Changes'}
          </button>
        </div>

        {#if activeTab === 'profile'}
          <div class="space-y-12 animate-in fade-in duration-500">
            <!-- Profile Settings -->
            <section class="space-y-6">
              <div class="flex items-center gap-6">
                <div class="relative group">
                  <img 
                    src={profile.avatar_url || `https://ui-avatars.com/api/?name=${profile.display_name}&background=00FFB2&color=000`} 
                    alt="Avatar" 
                    class="w-24 h-24 rounded-full object-cover border-4 border-white/5 group-hover:border-brand-primary/50 transition-all"
                  />
                  <label class="absolute inset-0 flex items-center justify-center bg-black/50 opacity-0 group-hover:opacity-100 rounded-full cursor-pointer transition-all">
                    <Upload size={20} />
                    <input type="file" accept="image/*" class="hidden" onchange={handleAvatarUpload} />
                  </label>
                </div>
                <div>
                  <h3 class="text-xl font-bold">{profile.display_name}</h3>
                  <p class="text-sm text-gray-500">@{profile.username}</p>
                </div>
              </div>
              
              <div class="grid md:grid-cols-2 gap-6">
                <div class="space-y-2">
                  <label class="text-sm font-semibold text-gray-400">Display Name</label>
                  <input type="text" bind:value={profile.display_name} class="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-brand-primary outline-none transition-colors" />
                </div>
                <div class="space-y-2">
                  <label class="text-sm font-semibold text-gray-400">Bio</label>
                  <textarea bind:value={profile.bio} rows="1" class="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-brand-primary outline-none transition-colors resize-none"></textarea>
                </div>
              </div>
            </section>

            <!-- Links -->
            <section class="space-y-6">
              <div class="flex justify-between items-center">
                <h2 class="text-xl font-bold flex items-center gap-2">Links & Socials</h2>
                <button onclick={addLink} class="text-brand-primary flex items-center gap-2 hover:bg-brand-primary/10 px-4 py-2 rounded-full transition-colors">
                  <Plus size={20} /> Add Link
                </button>
              </div>

              <div use:dndzone={{items: links, flipDurationMs}} onconsider={handleDndConsider} onfinalize={handleDndFinalize} class="space-y-4">
                {#each links as link (link.id)}
                  <div animate:flip={{duration: flipDurationMs}} class="glass p-4 rounded-2xl flex items-center gap-4 group">
                    <div class="cursor-grab active:cursor-grabbing text-gray-600 hover:text-white transition-colors">
                      <GripVertical size={20} />
                    </div>
                    <div class="flex-1 grid md:grid-cols-2 gap-4">
                      <input type="text" bind:value={link.title} placeholder="Title" class="bg-white/5 border border-white/5 rounded-xl px-4 py-2 outline-none focus:border-brand-primary/50" />
                      <input type="text" bind:value={link.url} placeholder="URL" class="bg-white/5 border border-white/5 rounded-xl px-4 py-2 outline-none focus:border-brand-primary/50" />
                    </div>
                    <button onclick={() => removeLink(link.id)} class="text-gray-600 hover:text-red-400 transition-colors p-2"><Trash2 size={20} /></button>
                  </div>
                {/each}
              </div>
            </section>
          </div>

        {:else if activeTab === 'appearance'}
          <div class="space-y-8 animate-in fade-in duration-500">
            <section class="space-y-6">
              <h3 class="text-xl font-bold">Theme Presets</h3>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                {#each themes as theme}
                  <button 
                    onclick={() => selectTheme(theme)}
                    class="p-4 rounded-2xl border-2 transition-all text-left space-y-2"
                    style="background: {theme.bg}; border-color: {profile.theme.bg_value === theme.bg ? theme.accent : 'transparent'}"
                  >
                    <div class="w-8 h-8 rounded-full" style="background: {theme.accent}"></div>
                    <p class="text-xs font-bold" style="color: {theme.text}">{theme.name}</p>
                  </button>
                {/each}
              </div>
            </section>

            <section class="space-y-6">
              <h3 class="text-xl font-bold">Custom Colors</h3>
              <div class="grid md:grid-cols-3 gap-6">
                <div class="space-y-2">
                  <label class="text-sm font-semibold text-gray-400">Background</label>
                  <div class="flex gap-2">
                    <input type="color" bind:value={profile.theme.bg_value} class="w-12 h-12 rounded-lg bg-transparent border-0 cursor-pointer" />
                    <input type="text" bind:value={profile.theme.bg_value} class="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-sm" />
                  </div>
                </div>
                <div class="space-y-2">
                  <label class="text-sm font-semibold text-gray-400">Accent</label>
                  <div class="flex gap-2">
                    <input type="color" bind:value={profile.theme.accent_color} class="w-12 h-12 rounded-lg bg-transparent border-0 cursor-pointer" />
                    <input type="text" bind:value={profile.theme.accent_color} class="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-sm" />
                  </div>
                </div>
                <div class="space-y-2">
                  <label class="text-sm font-semibold text-gray-400">Text</label>
                  <div class="flex gap-2">
                    <input type="color" bind:value={profile.theme.text_color} class="w-12 h-12 rounded-lg bg-transparent border-0 cursor-pointer" />
                    <input type="text" bind:value={profile.theme.text_color} class="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-sm" />
                  </div>
                </div>
              </div>
            </section>
          </div>

        {:else if activeTab === 'seo'}
          <div class="space-y-8 animate-in fade-in duration-500">
            <section class="space-y-6">
              <div class="space-y-2">
                <label class="text-sm font-semibold text-gray-400">Meta Title</label>
                <input type="text" bind:value={profile.seo.title} placeholder="e.g. Esa Labs | Digital Creative" class="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-brand-primary outline-none transition-colors" />
                <p class="text-[10px] text-gray-500">Appears in Google search results and browser tabs.</p>
              </div>
              <div class="space-y-2">
                <label class="text-sm font-semibold text-gray-400">Meta Description</label>
                <textarea bind:value={profile.seo.description} rows="3" placeholder="Tell Google what your profile is about..." class="w-full bg-white/5 border border-white/10 rounded-xl p-4 focus:border-brand-primary outline-none transition-colors resize-none"></textarea>
              </div>
            </section>
          </div>

        {:else if activeTab === 'analytics'}
          <div class="space-y-8 animate-in fade-in duration-500">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
              <div class="glass p-6 rounded-3xl space-y-1">
                <p class="text-gray-500 text-xs font-bold uppercase">Total Clicks</p>
                <p class="text-3xl font-bold">{analytics.length}</p>
              </div>
            </div>

            <section class="space-y-4">
              <h3 class="text-xl font-bold">Recent Activity</h3>
              <div class="glass rounded-3xl overflow-hidden">
                <table class="w-full text-left text-sm">
                  <thead class="bg-white/5 text-gray-400 uppercase text-[10px] font-bold">
                    <tr>
                      <th class="p-4">Link ID</th>
                      <th class="p-4">Time</th>
                      <th class="p-4">Device</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-white/5">
                    {#each analytics.slice(0, 10) as event}
                      <tr>
                        <td class="p-4 font-mono text-xs">{event.link_id}</td>
                        <td class="p-4 text-gray-400">{new Date(event.created_at).toLocaleString()}</td>
                        <td class="p-4 text-gray-400 truncate max-w-[200px]">{event.user_agent}</td>
                      </tr>
                    {/each}
                  </tbody>
                </table>
              </div>
            </section>
          </div>
        {/if}
      </div>
    {/if}
  </main>
</div>
