import boto3
import base64

from ansible.errors import AnsibleFilterError

kms = boto3.client('kms')
MISSING = object()

def kms_decrypt(ciphertext, context=MISSING):
    try:
        decoded = base64.b64decode(ciphertext)
	plaintext = ''
	if context is MISSING:
            plaintext = kms.decrypt(CiphertextBlob=decoded).get('Plaintext')
	else:
            plaintext = kms.decrypt(CiphertextBlob=decoded, EncryptionContext=context).get('Plaintext')
	return plaintext
    except Exception as e:
        raise AnsibleFilterError(e)

def kms_encrypt(plaintext, key):
    return base64.b64encode(kms.encrypt(KeyId=key,Plaintext=plaintext).get('CiphertextBlob'))

class FilterModule(object):
    def filters(self):
        return { 'kms_encrypt': kms_encrypt, 'kms_decrypt': kms_decrypt }
