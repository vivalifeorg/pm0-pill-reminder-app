

import phaxio
import os

import ssl

try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    # Legacy Python that doesn't verify HTTPS certificates by default
    pass
else:
    # Handle target environment that doesn't support HTTPS verification
    ssl._create_default_https_context = _create_unverified_https_context


api = phaxio.PhaxioApi(os.environ['API_KEY'], os.environ['API_SECRET'])
response = api.Fax.send(to=['18558237571'],
    files='../pm0/TestPages/FaxJPG1.jpg')
print(response.data.id)


