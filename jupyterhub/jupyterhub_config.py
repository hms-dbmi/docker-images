# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os
import types
import dockerspawner
import hvac
import errno

c = get_config()

# We retrieve all secrets and configurations from Vault using this client
# Only the VAULT_TOKEN and VAULT_BASE are kept in environment variables
client = hvac.Client(url='https://vault.aws.dbmi.hms.harvard.edu:443', verify=False)
client.token = os.environ['VAULT_TOKEN']
vault_base = os.environ['VAULT_BASE']

def readVaultValue(variableKey):
    return client.read(vault_base + variableKey)['data']['value']

# Spawn single-user servers as Docker containers
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
# Spawn containers from this image
c.DockerSpawner.container_image = avillachlab/jupyter-notebook # readVaultValue('DOCKER_NOTEBOOK_IMAGE')
# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
spawn_cmd = start-singleuser.sh # readVaultValue('DOCKER_SPAWN_CMD')
c.DockerSpawner.extra_create_kwargs.update({ 'command': spawn_cmd })
# Connect containers to this Docker network
network_name = jupyterhub-network # readVaultValue('DOCKER_NETWORK_NAME')
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { 'network_mode': network_name }
# Explicitly set notebook directory because we'll be mounting a host volume to
# it.  Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir = /home/jovyan/work # readVaultValue('DOCKER_NOTEBOOK_DIR')
c.DockerSpawner.notebook_dir = notebook_dir
# Remove containers once they are stopped
c.DockerSpawner.remove_containers = True
# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = 'jupyterhub'
c.JupyterHub.hub_port = 8080



# Get SSL Cert and Key from Vault and save them in /tmp/ssl so they are in memory only
sslPath = '/tmp/ssl'

try:
    os.mkdir(sslPath, 0o700)
except OSError as exc:
    if exc.errno == errno.EEXIST and os.path.isdir(sslPath):
        pass
    else:
        raise

def writeFile(filepath, value):
    file = open(filepath, 'w+')
    file.truncate()
    file.write(value)
    file.close()

def writeCertOrKey(filename, value):
    filepath = os.path.join(sslPath, filename)
    writeFile(filepath, value)
    os.chmod(filepath, 0o600)

# writeCertOrKey('jupyterhub.crt', readVaultValue('SSL_CERT'))
# writeCertOrKey('jupyterhub.key', readVaultValue('SSL_KEY'))

# TLS config
c.JupyterHub.port = 443
c.JupyterHub.ssl_key = '/tmp/ssl/jupyterhub.key'
c.JupyterHub.ssl_cert = '/tmp/ssl/jupyterhub.crt'

# Authenticate users with Auth0 OAuth
#c.Auth0OAuthenticator.client_id = readVaultValue('AUTH0_CLIENT_ID')
#c.Auth0OAuthenticator.client_secret = readVaultValue('AUTH0_CLIENT_SECRET')
#c.Auth0OAuthenticator.oauth_callback_url = readVaultValue('AUTH0_CALLBACK_URL')
#c.Auth0OAuthenticator.webtask_base_url = 'https://avillachlab.us.webtask.io/connection_details_base64/'
#c.JupyterHub.authenticator_class = 'oauthenticator.auth0.Auth0OAuthenticator'
c.JupyterHub.authenticator_class = 'dummyauthenticator.DummyAuthenticator'
c.DummyAuthenticator.password = "password"

# Persist hub data on volume mounted inside container
data_dir = /data #readVaultValue('DATA_VOLUME_CONTAINER')
c.JupyterHub.db_url = os.path.join('sqlite:///', data_dir, 'jupyterhub.sqlite')
c.JupyterHub.cookie_secret_file = os.path.join(data_dir,
    'jupyterhub_cookie_secret')

# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
# also mount a readonly and shared folder
c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': notebook_dir, 'jupyterhub-shared': os.path.join(notebook_dir, 'shared') }
c.DockerSpawner.read_only_volumes = { 'jupyterhub-readonly': os.path.join(notebook_dir, 'readonly') }
c.DockerSpawner.extra_create_kwargs.update({ 'volume_driver': 'local' })

c.DockerSpawner.format_volume_name = dockerspawner.volumenamingstrategy.escaped_format_volume_name

# Write userlist from vault
writeFile('/tmp/userlist', 'admin')

# Whitlelist users and admins
c.Authenticator.whitelist = whitelist = set()
c.Authenticator.admin_users = admin = set()
c.JupyterHub.admin_access = True
pwd = os.path.dirname(__file__)
with open(os.path.join('/tmp', 'userlist')) as f:
    for line in f:
        if not line:
            continue
        parts = line.split()
        name = parts[0]
        whitelist.add(name)
        if len(parts) > 1 and parts[1] == 'admin':
            admin.add(name)
