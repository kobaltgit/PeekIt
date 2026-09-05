<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { convertFileSrc } from '@tauri-apps/api/core';
  import type { FilePreviewInfo, AppLanguage } from '../types';
  import { t } from '../i18n';

  export let file: FilePreviewInfo;
  export let lang: AppLanguage = 'ru';
  export let autoplay: boolean = true;
  export let initialVolume: number = 0.8;

  let mediaEl: HTMLVideoElement | HTMLAudioElement;
  let isPlaying = false;
  let currentTime = 0;
  let duration = 0;
  let volume = initialVolume;
  let isMuted = false;
  let isLooping = false;
  let playbackRate = 1;

  $: isVideo = file.category === 'video';

  // Unload and stop media when component unmounts
  onDestroy(() => {
    if (mediaEl) {
      mediaEl.pause();
      mediaEl.removeAttribute('src');
      mediaEl.load();
    }
  });

  // Format time mm:ss
  function formatTime(seconds: number): string {
    if (isNaN(seconds) || seconds < 0) return '00:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  function togglePlay() {
    if (!mediaEl) return;
    if (isPlaying) {
      mediaEl.pause();
    } else {
      mediaEl.play().catch(console.warn);
    }
  }

  function toggleMute() {
    if (!mediaEl) return;
    mediaEl.muted = !mediaEl.muted;
    isMuted = mediaEl.muted;
  }

  function onVolumeChange(e: Event) {
    const val = parseFloat((e.target as HTMLInputElement).value);
    volume = val;
    if (mediaEl) {
      mediaEl.volume = val;
      mediaEl.muted = val === 0;
      isMuted = mediaEl.muted;
    }
  }

  function onSeek(e: Event) {
    const val = parseFloat((e.target as HTMLInputElement).value);
    if (mediaEl && duration > 0) {
      mediaEl.currentTime = (val / 100) * duration;
    }
  }

  function toggleLoop() {
    isLooping = !isLooping;
    if (mediaEl) mediaEl.loop = isLooping;
  }

  function cycleSpeed() {
    const speeds = [0.5, 1, 1.25, 1.5, 2];
    const nextIdx = (speeds.indexOf(playbackRate) + 1) % speeds.length;
    playbackRate = speeds[nextIdx];
    if (mediaEl) mediaEl.playbackRate = playbackRate;
  }

  // Convert local Windows path to Tauri asset URL
  $: mediaSrc = file?.path ? convertFileSrc(file.path) : '';

  $: progressPercent = duration > 0 ? (currentTime / duration) * 100 : 0;
</script>

<div class="media-container {isVideo ? 'video-mode' : 'audio-mode'}">
  {#if isVideo}
    <div class="video-viewport">
      <video
        bind:this={mediaEl}
        src={mediaSrc}
        autoplay={autoplay}
        loop={isLooping}
        on:play={() => (isPlaying = true)}
        on:pause={() => (isPlaying = false)}
        on:timeupdate={() => (currentTime = mediaEl.currentTime)}
        on:loadedmetadata={() => {
          duration = mediaEl.duration;
          mediaEl.volume = volume;
        }}
        on:click={togglePlay}
      >
        <track kind="captions" />
      </video>
    </div>
  {:else}
    <div class="audio-viewport">
      <audio
        bind:this={mediaEl}
        src={mediaSrc}
        autoplay={autoplay}
        loop={isLooping}
        on:play={() => (isPlaying = true)}
        on:pause={() => (isPlaying = false)}
        on:timeupdate={() => (currentTime = mediaEl.currentTime)}
        on:loadedmetadata={() => {
          duration = mediaEl.duration;
          mediaEl.volume = volume;
        }}
      ></audio>

      <div class="audio-card">
        <div class="audio-disc {isPlaying ? 'spinning' : ''}">
          <svg viewBox="0 0 24 24" width="48" height="48" fill="none" stroke="currentColor" stroke-width="1.8">
            <circle cx="12" cy="12" r="10" />
            <circle cx="12" cy="12" r="3" />
            <path d="M12 2a10 10 0 0 1 10 10" stroke-dasharray="4 4" />
          </svg>
        </div>
        <div class="audio-info">
          <div class="audio-title">{file.fileName}</div>
          <div class="audio-meta">
            <span>{file.sizeFormatted}</span>
            <span class="dot">•</span>
            <span>{file.extension.toUpperCase()}</span>
          </div>
        </div>

        <!-- Dynamic Equalizer Bars -->
        <div class="eq-bars {isPlaying ? 'active' : ''}">
          <div class="bar bar-1"></div>
          <div class="bar bar-2"></div>
          <div class="bar bar-3"></div>
          <div class="bar bar-4"></div>
          <div class="bar bar-5"></div>
        </div>
      </div>
    </div>
  {/if}

  <!-- Fluent Media Controller -->
  <div class="controller-bar">
    <!-- Progress Scrubber -->
    <div class="timeline-row">
      <span class="time-label">{formatTime(currentTime)}</span>
      <div class="scrubber-wrapper">
        <input
          type="range"
          min="0"
          max="100"
          step="0.1"
          value={progressPercent}
          on:input={onSeek}
          class="scrubber-slider"
        />
        <div class="scrubber-progress" style="width: {progressPercent}%"></div>
      </div>
      <span class="time-label">{formatTime(duration)}</span>
    </div>

    <!-- Buttons Row -->
    <div class="controls-row">
      <div class="left-controls">
        <button class="btn-ctrl play-btn" on:click={togglePlay} title={isPlaying ? t('pause', lang) : t('play', lang)}>
          {#if isPlaying}
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
              <rect x="6" y="4" width="4" height="16" rx="1.5" />
              <rect x="14" y="4" width="4" height="16" rx="1.5" />
            </svg>
          {:else}
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
              <path d="M5 3l14 9-14 9V3z" />
            </svg>
          {/if}
        </button>

        <button class="btn-ctrl" on:click={toggleLoop} class:active={isLooping} title={t('loop', lang)}>
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="17 1 21 5 17 9" />
            <path d="M3 11V9a4 4 0 0 1 4-4h14" />
            <polyline points="7 23 3 19 7 15" />
            <path d="M21 13v2a4 4 0 0 1-4 4H3" />
          </svg>
        </button>

        <button class="btn-ctrl speed-btn" on:click={cycleSpeed} title={t('speed', lang)}>
          {playbackRate}x
        </button>
      </div>

      <div class="right-controls">
        <button class="btn-ctrl" on:click={toggleMute} title={isMuted ? t('unmute', lang) : t('mute', lang)}>
          {#if isMuted || volume === 0}
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
              <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
              <line x1="23" y1="9" x2="17" y2="15" />
              <line x1="17" y1="9" x2="23" y2="15" />
            </svg>
          {:else}
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2">
              <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
              <path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07" />
            </svg>
          {/if}
        </button>

        <div class="volume-slider-box">
          <input
            type="range"
            min="0"
            max="1"
            step="0.05"
            value={isMuted ? 0 : volume}
            on:input={onVolumeChange}
            class="vol-slider"
          />
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  .media-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    width: 100%;
    background: transparent;
    position: relative;
    user-select: none;
  }

  .video-viewport {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #000;
    overflow: hidden;
    position: relative;
  }

  .video-viewport video {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
    outline: none;
    cursor: pointer;
  }

  .audio-viewport {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 32px;
  }

  .audio-card {
    display: flex;
    align-items: center;
    gap: 24px;
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    padding: 24px 32px;
    border-radius: 16px;
    box-shadow: var(--shadow-elevation);
    backdrop-filter: blur(20px);
    max-width: 520px;
    width: 100%;
  }

  .audio-disc {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.2), rgba(147, 51, 234, 0.2));
    border: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--accent);
    flex-shrink: 0;
    transition: transform 0.3s ease;
  }

  .audio-disc.spinning {
    animation: spin 8s linear infinite;
  }

  @keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }

  .audio-info {
    flex: 1;
    min-width: 0;
  }

  .audio-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--text-main);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    margin-bottom: 4px;
  }

  .audio-meta {
    font-size: 13px;
    color: var(--text-muted);
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .dot {
    opacity: 0.5;
  }

  /* Equalizer animation */
  .eq-bars {
    display: flex;
    align-items: flex-end;
    gap: 4px;
    height: 32px;
    width: 28px;
  }

  .bar {
    width: 4px;
    background: var(--accent);
    border-radius: 2px;
    height: 6px;
    transition: height 0.2s ease;
  }

  .eq-bars.active .bar-1 { animation: eqPulse 0.7s infinite alternate ease-in-out; }
  .eq-bars.active .bar-2 { animation: eqPulse 0.5s infinite alternate ease-in-out 0.15s; }
  .eq-bars.active .bar-3 { animation: eqPulse 0.8s infinite alternate ease-in-out 0.3s; }
  .eq-bars.active .bar-4 { animation: eqPulse 0.6s infinite alternate ease-in-out 0.2s; }
  .eq-bars.active .bar-5 { animation: eqPulse 0.75s infinite alternate ease-in-out 0.1s; }

  @keyframes eqPulse {
    0% { height: 6px; }
    100% { height: 28px; }
  }

  /* Fluent Controller Bar */
  .controller-bar {
    background: var(--bg-card);
    border-top: 1px solid var(--border-color);
    padding: 12px 20px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    backdrop-filter: blur(16px);
  }

  .timeline-row {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .time-label {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: var(--text-muted);
    min-width: 42px;
    text-align: center;
  }

  .scrubber-wrapper {
    flex: 1;
    position: relative;
    height: 6px;
    background: var(--bg-subtle);
    border-radius: 3px;
    display: flex;
    align-items: center;
    cursor: pointer;
  }

  .scrubber-progress {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    background: var(--accent);
    border-radius: 3px;
    pointer-events: none;
  }

  .scrubber-slider {
    position: absolute;
    width: 100%;
    height: 100%;
    opacity: 0;
    cursor: pointer;
    z-index: 2;
    margin: 0;
  }

  .controls-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .left-controls, .right-controls {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .btn-ctrl {
    background: transparent;
    border: 1px solid transparent;
    color: var(--text-main);
    border-radius: 8px;
    padding: 6px 10px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.15s ease;
  }

  .btn-ctrl:hover {
    background: var(--bg-hover);
    border-color: var(--border-hover);
  }

  .btn-ctrl.active {
    color: var(--accent);
    background: rgba(59, 130, 246, 0.15);
  }

  .play-btn {
    width: 38px;
    height: 38px;
    background: var(--accent);
    color: #fff;
    border-radius: 50%;
    padding: 0;
  }

  .play-btn:hover {
    background: var(--accent-hover);
    box-shadow: 0 0 12px var(--accent-glow);
  }

  .speed-btn {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    font-weight: 600;
  }

  .volume-slider-box {
    width: 70px;
    display: flex;
    align-items: center;
  }

  .vol-slider {
    width: 100%;
    height: 4px;
    accent-color: var(--accent);
    cursor: pointer;
  }
</style>
