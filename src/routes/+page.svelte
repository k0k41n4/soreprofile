<script lang="ts">
  import { ArrowRight, Sparkles, Layout, Zap } from 'lucide-svelte';
</script>

<div class="relative overflow-hidden">
  <!-- Gradient Background -->
  <div class="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[600px] bg-brand-primary/10 blur-[120px] -z-10 rounded-full"></div>
  
  <nav class="container mx-auto px-6 py-8 flex justify-between items-center">
    <div class="flex items-center gap-2">
      <div class="w-8 h-8 bg-brand-primary rounded-lg rotate-12 flex items-center justify-center">
        <span class="text-black font-bold -rotate-12">S</span>
      </div>
      <span class="text-xl font-bold tracking-tighter uppercase">Soreprofile</span>
    </div>
    <div class="flex gap-4">
      <a href="/login" class="btn-secondary px-6 py-2 text-sm">Login</a>
      <a href="/register" class="btn-primary px-6 py-2 text-sm">Join for Free</a>
    </div>
  </nav>

  <main class="container mx-auto px-6 pt-20 pb-32">
    <div class="max-w-3xl mx-auto text-center space-y-8">
      <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-primary/10 border border-brand-primary/20 text-brand-primary text-xs font-semibold uppercase tracking-widest animate-pulse">
        <Sparkles size={14} />
        The Premium Business Card
      </div>
      
      <h1 class="text-6xl md:text-8xl font-bold tracking-tighter leading-[0.9]">
        Make your <span class="text-brand-primary">Sore</span> profile shine.
      </h1>
      
      <p class="text-xl text-gray-400 max-w-xl mx-auto leading-relaxed">
        The ultimate digital business card. Share your links, social media, and bio in a beautiful, high-performance profile.
      </p>

      <div class="flex flex-col sm:flex-row gap-4 justify-center pt-4">
        <a href="/register" class="btn-primary px-8 py-4 text-lg">
          Get Started
          <ArrowRight size={20} />
        </a>
        <a href="#features" class="btn-secondary px-8 py-4 text-lg">
          See Features
        </a>
      </div>
    </div>

    <!-- Feature Grid -->
    <div id="features" class="grid md:grid-cols-3 gap-8 mt-40">
      <div class="glass p-8 rounded-3xl space-y-4 glass-hover">
        <div class="w-12 h-12 rounded-2xl bg-brand-primary/20 flex items-center justify-center text-brand-primary">
          <Layout size={24} />
        </div>
        <h3 class="text-xl font-bold">Custom Layouts</h3>
        <p class="text-gray-400">Personalize your profile with our intuitive drag-and-drop builder.</p>
      </div>

      <div class="glass p-8 rounded-3xl space-y-4 glass-hover">
        <div class="w-12 h-12 rounded-2xl bg-purple-500/20 flex items-center justify-center text-purple-400">
          <Zap size={24} />
        </div>
        <h3 class="text-xl font-bold">Lightning Fast</h3>
        <p class="text-gray-400">Built with SvelteKit for near-instant page loads and smooth transitions.</p>
      </div>

      <div class="glass p-8 rounded-3xl space-y-4 glass-hover">
        <div class="w-12 h-12 rounded-2xl bg-blue-500/20 flex items-center justify-center text-blue-400">
          <Sparkles size={24} />
        </div>
        <h3 class="text-xl font-bold">AI Bio Generator</h3>
        <p class="text-gray-400">Let our Tequila Feel AI craft the perfect bio for your brand.</p>
      </div>
    </div>
  </main>

  <footer class="border-t border-white/5 py-12">
    <div class="container mx-auto px-6 text-center text-gray-500 text-sm">
      &copy; 2026 Sorelabs. All rights reserved.
    </div>
  </footer>
</div>
