#include "cavacore.h"
#include "input/common.h"
#include "input/pipewire.h"
#include "output/raw.h"
#include <math.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static volatile sig_atomic_t g_running = 1;

static void handle_sigint(int sig) {
  (void)sig;
  g_running = 0;
}

// Smooth a value exponentially
static double smooth(double current, double target, double factor) {
  return current * (1.0 - factor) + target * factor;
}

int main(void) {
  // --- Init audio_data ---
  struct audio_data audio = {0};
  pthread_mutex_init(&audio.lock, NULL);
  audio.format = 16;
  audio.rate = 48000;
  audio.channels = 2;
  audio.IEEE_FLOAT = 0;
  audio.input_buffer_size = 4096;
  audio.cava_buffer_size = 8192;
  audio.cava_in = calloc(audio.cava_buffer_size, sizeof(double));
  if (!audio.cava_in) {
    perror("calloc");
    return 1;
  }
  audio.threadparams = 0;
  audio.terminate = 0;
  audio.samples_counter = 0;
  audio.autoconnect = 1;
  audio.active = 1;
  audio.remix = 0;
  audio.virtual_node = 0;
  audio.source = strdup("auto");

  // --- Start PipeWire thread ---
  pthread_t pw_thread;
  if (pthread_create(&pw_thread, NULL, input_pipewire, &audio) != 0) {
    perror("pthread_create");
    return 1;
  }
  signal(SIGINT, handle_sigint);

  // --- Init Cava ---
  const int bars = 16;
  int autosens = 1;
  double noise_reduction = 0.77;
  int low_cutoff = 50;
  int high_cutoff = 10000;

  struct cava_plan *plan = cava_init(bars, audio.rate, audio.channels, autosens,
                                     noise_reduction, low_cutoff, high_cutoff);
  if (!plan || plan->status != 0) {
    fprintf(stderr, "cava_init failed\n");
    return 1;
  }

  double *cava_out = calloc(bars * audio.channels, sizeof(double));
  if (!cava_out) {
    perror("calloc cava_out");
    return 1;
  }

  // Smoothed values for output
  double smooth_bass = 0.0;
  double smooth_mid = 0.0;
  double smooth_treble = 0.0;
  double smooth_level = 0.0;

  const double smooth_factor = 0.3;

  // --- Main loop ---
  while (g_running) {
    int new_samples = 0;
    pthread_mutex_lock(&audio.lock);
    new_samples = audio.samples_counter;
    if (new_samples > audio.cava_buffer_size)
      new_samples = audio.cava_buffer_size;

    double *chunk = NULL;
    if (new_samples > 0) {
      chunk = malloc(sizeof(double) * new_samples);
      if (!chunk) {
        pthread_mutex_unlock(&audio.lock);
        perror("malloc chunk");
        break;
      }
      memcpy(chunk, audio.cava_in, sizeof(double) * new_samples);
      audio.samples_counter = 0;
    }
    pthread_mutex_unlock(&audio.lock);

    if (new_samples > 0 && chunk) {
      cava_execute(chunk, new_samples, cava_out, plan);
      free(chunk);

      for (int i = 0; i < bars; i++) {
        printf("%.3f", cava_out[i]);
        if (i < bars - 1)
          printf(";");
      }
      printf("\n");
      fflush(stdout);
    }

    usleep(16000); // ~60 fps
  }

  // --- Cleanup ---
  signal_terminate(&audio);
  pthread_join(pw_thread, NULL);
  cava_destroy(plan);
  free(cava_out);
  pthread_mutex_destroy(&audio.lock);
  free(audio.cava_in);
  free(audio.source);
  return 0;
}
