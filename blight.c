#include <stdio.h>
#include <tox/toxdns.h>
#include <AL/al.h>

#ifdef __cplusplus
extern "C" {
#endif

int blight_decrypt_dns3(void *dns3_object, uint8_t *tox_id, uint8_t *id_record, uint32_t id_record_len,
                        uint32_t *request_id)
{
	return tox_decrypt_dns3_TXT(dns3_object, tox_id, id_record, id_record_len, *request_id);
}

void blight_play_audio_buffer(ALuint alSource, const int16_t *data, int samples, unsigned channels, int sampleRate)
{ 
	ALuint bufid;
	ALint processed = 0, queued = 16;
	alGetSourcei(alSource, AL_BUFFERS_PROCESSED, &processed);
	alGetSourcei(alSource, AL_BUFFERS_QUEUED, &queued);
	alSourcei(alSource, AL_LOOPING, AL_FALSE);

#ifdef DEBUG
	printf("play_audio_buffer: processed: %d, queued: %d ", processed, queued);
#endif

	if (processed)
	{
		ALuint bufids[processed];

#ifdef DEBUG
		printf("bufids (before): ");
		for (int i = 0; i < processed; i++)
			printf("%d ", bufids[i]);
		printf("\n");
#endif

		alSourceUnqueueBuffers(alSource, processed, bufids);

#ifdef DEBUG
		printf("bufids (after): ");
		for (int j = 0; j < processed; j++)
			printf("%d ", bufids[j]);
		printf("\n");
#endif

		alDeleteBuffers(processed - 1, bufids + 1);
		bufid = bufids[0];

#ifdef DEBUG
		printf("bufid: %d\n", bufid);
#endif
	}
	else if (queued < 16)
	{
		alGenBuffers(1, &bufid);
	}
	else
	{
		printf("Audio: Dropped frame\n");
		return;
	}

	alBufferData(bufid, (channels == 1) ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16, data,
			samples * 2 * channels, sampleRate);
	alSourceQueueBuffers(alSource, 1, &bufid);

	ALint state;
	alGetSourcei(alSource, AL_SOURCE_STATE, &state);
	if (state != AL_PLAYING)
		alSourcePlay(alSource);
}
#ifdef __cplusplus
}
#endif
