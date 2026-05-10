<script lang="ts">
  import { supabase } from '$lib/supabase';
  import { Sparkles } from 'lucide-svelte';

  async function signInWithGoogle() {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/dashboard`
      }
    });
    if (error) alert(error.message);
  }
</script>

<div class="min-h-screen flex items-center justify-center p-6">
  <div class="glass max-w-md w-full p-12 rounded-[40px] space-y-8 text-center relative overflow-hidden">
    <div class="absolute -top-20 -right-20 w-40 h-40 bg-brand-primary/20 blur-[60px] rounded-full"></div>
    
    <div class="space-y-4">
      <div class="w-16 h-16 bg-brand-primary rounded-2xl rotate-12 flex items-center justify-center mx-auto mb-8 shadow-2xl shadow-brand-primary/20">
        <span class="text-3xl text-black font-bold -rotate-12">S</span>
      </div>
      <h1 class="text-4xl font-bold tracking-tight">Welcome Back</h1>
      <p class="text-gray-400">Sign in to manage your Soreprofile</p>
    </div>

    <button 
      onclick={signInWithGoogle}
      class="w-full bg-white text-black font-bold py-4 rounded-2xl flex items-center justify-center gap-3 hover:bg-gray-100 transition-all active:scale-[0.98]"
    >
      <img src="https://www.google.com/favicon.ico" alt="Google" class="w-5 h-5" />
      Continue with Google
    </button>

    <p class="text-xs text-gray-600">
      By continuing, you agree to our Terms and Privacy Policy.
    </p>

    <div class="pt-8">
      <a href="/" class="text-sm text-gray-400 hover:text-brand-primary transition-colors">
        &larr; Back to home
      </a>
    </div>
  </div>
</div>
