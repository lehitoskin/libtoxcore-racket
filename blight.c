#include <tox/toxdns.h>

int blight_decrypt_dns3(void *dns3_object, uint8_t *tox_id, uint8_t *id_record, uint32_t id_record_len,
                        uint32_t *request_id)
{
	return tox_decrypt_dns3_TXT(dns3_object, tox_id, id_record, id_record_len, *request_id);
}
