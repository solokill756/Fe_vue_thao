<template>
  <div>
    <!-- Divider -->
    <div class="relative">
      <div class="absolute inset-0 flex items-center">
        <div class="w-full border-t border-gray-300"></div>
      </div>
      <div class="relative flex justify-center text-sm">
        <span class="px-2 bg-white text-gray-500">
          {{ $t('auth.social') }}
        </span>
      </div>
    </div>

    <!-- Social Login -->
    <div
        id="google-signin-button"
        class="my-4 w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors cursor-pointer"
      >
        <img
          class="h-5 w-5 mr-2"
          src="https://www.svgrepo.com/show/475656/google-color.svg"
          alt="Google"
        />
        <span>Google</span>
      </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue';

const emit = defineEmits<{
  'google-login': [idToken: string];
}>();

const config = useRuntimeConfig();
const googleClientId = config.public.googleClientId;

// Debug: Log client ID (remove in production)
if (process.dev) {
  console.log('Google Client ID configured:', googleClientId ? 'Yes' : 'No');
  if (googleClientId) {
    console.log('Client ID format:', googleClientId.substring(0, 20) + '...');
  }
}

let googleScriptLoaded = false;

const loadGoogleScript = (): Promise<void> => {
  return new Promise((resolve, reject) => {
    if (googleScriptLoaded) {
      resolve();
      return;
    }

    if (typeof window !== 'undefined' && (window as any).google) {
      googleScriptLoaded = true;
      resolve();
      return;
    }

    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.defer = true;
    script.onload = () => {
      googleScriptLoaded = true;
      resolve();
    };
    script.onerror = () => {
      reject(new Error('Failed to load Google Sign-In script'));
    };
    document.head.appendChild(script);
  });
};

const initializeGoogleSignIn = async () => {
  if (!process.client) return;

  // Check if Google Client ID is configured
  if (!googleClientId || googleClientId === 'your-google-client-id.apps.googleusercontent.com') {
    console.warn('Google Client ID is not configured. Please set GOOGLE_CLIENT_ID in your .env file.');
    // Hide the button if client ID is not configured
    const button = document.getElementById('google-signin-button');
    if (button) {
      button.style.display = 'none';
    }
    return;
  }

  try {
    await loadGoogleScript();

    // Wait a bit for Google script to be fully ready
    await new Promise((resolve) => setTimeout(resolve, 100));

    if (!(window as any).google) {
      console.error('Google Sign-In script not loaded');
      return;
    }

    const google = (window as any).google;

    // Check if accounts.id is available
    if (!google.accounts || !google.accounts.id) {
      console.error('Google accounts.id API not available');
      return;
    }

    try {
      google.accounts.id.initialize({
        client_id: googleClientId,
        callback: handleCredentialResponse,
      });
    } catch (initError: any) {
      console.error('Error initializing Google accounts.id:', initError);
      throw initError;
    }

    const buttonElement = document.getElementById('google-signin-button');
    if (!buttonElement) {
      console.error('Google sign-in button element not found');
      return;
    }

    // Clear any existing content
    buttonElement.innerHTML = '';

    try {
      google.accounts.id.renderButton(buttonElement, {
        theme: 'outline',
        size: 'large',
        width: '100%',
        text: 'signin_with',
        locale: 'vi',
      });
      console.log('Google Sign-In button rendered successfully');
    } catch (renderError: any) {
      console.error('Error rendering Google Sign-In button:', renderError);
      // Show error message to user
      buttonElement.innerHTML = `
        <div class="text-red-600 text-sm">
          ${renderError.message || 'Không thể tải nút đăng nhập Google'}
        </div>
      `;
    }
  } catch (error: any) {
    console.error('Error initializing Google Sign-In:', error);
    const button = document.getElementById('google-signin-button');
    if (button) {
      button.style.display = 'none';
    }
  }
};

const handleCredentialResponse = (response: any) => {
  console.log('Google credential response received:', {
    hasCredential: !!response.credential,
    error: response.error,
  });

  if (response.error) {
    console.error('Google Sign-In error:', response.error);
    // Handle specific errors
    if (response.error === 'popup_closed_by_user') {
      console.log('User closed the popup');
    } else if (response.error === 'access_denied') {
      console.error('Access denied by user');
    } else {
      console.error('Unknown Google Sign-In error:', response.error);
    }
    return;
  }

  if (response.credential) {
    emit('google-login', response.credential);
  } else {
    console.error('No credential in Google response:', response);
  }
};

onMounted(() => {
  if (process.client) {
    initializeGoogleSignIn();
  }
});
</script>
