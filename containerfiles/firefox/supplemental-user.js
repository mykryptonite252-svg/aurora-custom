/****************************************************************************
 * Supplemental overrides — layer on top of Phoenix, not a replacement.
 *
 * Confirmed against the full phoenix-unified.cfg (2026-08-14, direct grep,
 * not a summarized fetch): Phoenix does not touch media.peerconnection,
 * media.navigator.video, hardware video decode, or DRM/Widevine prefs in
 * either tier. Nothing here should conflict with a lockPref() from
 * Phoenix. If a future Phoenix update DOES lock one of these, this file
 * will fail silently on that line (locked prefs can't be overridden) —
 * check about:config after any Phoenix update to confirm these still hold.
 ****************************************************************************/

/* --- Switch Phoenix to Extended tier. Not install-time — this pref is
 * the actual switch (see docs/extended.md). Verified this does not touch
 * WebRTC/camera prefs; see containerfile-snippet.Containerfile for the
 * full reasoning on why Extended is safe for the video-call requirement. */
user_pref("browser.phoenix.extended", true);

/* --- WebRTC: hide LAN + tailnet IPs, but DO NOT break calls. */
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.ice.no_host", false);

/* --- Camera capture resolution (MX Brio is a 4K sensor). */
user_pref("media.navigator.video.default_width", 3840);
user_pref("media.navigator.video.default_height", 2160);
user_pref("media.navigator.video.default_fps", 30);
user_pref("media.navigator.video.enable_yuv_conversion", true);

/* --- Hardware video decode. Re-check LIBVA_DRIVER_NAME against the actual
 * desktop GPU once known — this was Intel iGPU specific on the G7 laptop. */
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);

/* --- Hardware video ENCODE for WebRTC — this is the side that actually
 * determines your outgoing camera feed's resolution/CPU load on a call,
 * not decode. Off by default in Firefox; Mozilla defaults to software
 * VP8/VP9 encode over hardware H.264 unless explicitly enabled. Confirmed
 * real pref via Bugzilla 1581902, not guessed. */
user_pref("media.webrtc.hw.h264.enabled", true);

/* --- Dark mode, no extension needed. IMPORTANT LIMITATION, be aware of
 * this rather than assume parity with Brave's --force-dark-mode flag:
 * Chromium's force-dark does real render-level color inversion on any
 * page. Firefox has no equivalent engine feature. This pref only flips
 * the signal a site receives for prefers-color-scheme — it makes Firefox
 * TELL sites "the user wants dark," and only sites that already ship a
 * dark theme will honor it. A site with no dark mode support stays light
 * regardless. If a specific site you use daily needs a real forced-dark
 * override, that still requires something like Dark Reader for that one
 * site — this pref alone won't be full parity with it. */
user_pref("layout.css.prefers-color-scheme.content-override", 0);
