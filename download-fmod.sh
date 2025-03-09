#!/usr/bin/env bash

LIBRARY_NAME="fmodstudioapi20222linux"
SYMLINK_NAME="fmodstudioapi"

PRINT_EVERYTHING=false

set -e

if [ -d "otherlibs/${LIBRARY_NAME}" ]; then
	echo "FMOD libraries are already available."
	[ -L "otherlibs/${SYMLINK_NAME}" -o -e "otherlibs/${SYMLINK_NAME}" ] && rm "otherlibs/${SYMLINK_NAME}"
	ln -s "${LIBRARY_NAME}" "otherlibs/${SYMLINK_NAME}"
	exit 0
fi

type jq 2>/dev/null >&2 || {
	echo "Installing jq..."
	sudo apt-get install -y jq
}

curl() {
	command curl \
		-H 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1' \
		-H 'Accept-Language: en-US,en;q=0.5' \
		"${@}"
}

echo_sensitive() {
	if "${PRINT_EVERYTHING}"; then
		echo "${@}"
	else
		echo "ok"
	fi
}

mkdir -p otherlibs

# Check if an account was created before
if [ -f "fmod-login.json" ]; then
	# Load existing account credentials from disk
	echo -n "Loading credentials from disk... "
	username="$(jq -r '.username' < "fmod-login.json")"
	password="$(jq -r '.password' < "fmod-login.json")"
	email="$(jq -r '.email' < "fmod-login.json")"
	echo "${email}"
else
	# Pick a domain
	echo -n "Choosing email domain... "
	mail_domain="$(curl -s 'https://api.mail.tm/domains' | jq -r '.["hydra:member"].[0].domain')"
	echo "${mail_domain}"

	# Generate credentials
	echo -n "Generating email... "
	username="$(dd if=/dev/urandom bs=1 count=30 2>/dev/null | base64 | sed 's/[\/+]//g' | tr '[:upper:]' '[:lower:]')"
	email="${username}@${mail_domain}"
	password="$(dd if=/dev/urandom bs=1 count=30 2>/dev/null | base64 | sed 's/[\/+]//g')"
	mail_auth="{\"address\":\"${email}\",\"password\":\"${password}\"}"
	echo "${email}"

	# Register api.mail.tm account
	echo -n "Registering api.mail.tm account... "
	mail_id="$(curl -s -H 'Content-Type: application/json' -d "${mail_auth}" -X POST 'https://api.mail.tm/accounts' | jq -r '.["id"]')"
	echo_sensitive "${mail_id}"

	# Authenticate with api.mail.tm
	echo -n "Authenticating with api.mail.tm... "
	mail_token="$(curl -s -H 'Content-Type: application/json' -d "${mail_auth}" -X POST 'https://api.mail.tm/token' | jq -r '.["token"]')"
	echo_sensitive "${mail_token}"

	# Send sign up request
	echo -n "Creating fmod.com account... "
	register_data="\"{ \\\"username\\\":\\\"${username}\\\", \\\"password\\\":\\\"${password}\\\", \\\"company\\\":\\\"\\\", \\\"email\\\":\\\"${username}%40${mail_domain}\\\", \\\"name\\\":\\\"${username}\\\", \\\"ml_news\\\":false, \\\"ml_release\\\":false, \\\"industry\\\":1 }\""
	register_response="$(curl -s \
		-X POST \
		-H 'Referer: https://www.fmod.com/profile/register' \
		-H 'Content-Type: text/plain;charset=UTF-8' \
		-H 'Origin: https://www.fmod.com' \
		-d "${register_data}" \
		'https://www.fmod.com/api-register')"
	echo_sensitive "${register_response}"

	# Keep checking for new mails until the registration mail arrives
	echo -n "Waiting for registration email... "
	while true; do
		mail_id="$(curl -s -H "Authorization: Bearer ${mail_token}" 'https://api.mail.tm/messages' | jq -r '.["hydra:member"].[0].id')"
		if [ "${mail_id}" = "null" ]; then
			sleep 3
		else
			break
		fi
	done
	echo_sensitive "${mail_id}"

	# Get the registration key
	echo -n "Getting registration key... "
	completion_url="$(curl -s -H "Authorization: Bearer ${mail_token}" "https://api.mail.tm/messages/${mail_id}" | jq -r '.text' | grep https | head -n1)"
	completion_key="$(echo -n "${completion_url}" | sed 's/.*\=//g')"
	echo_sensitive "${completion_key}"

	# Complete the registration
	echo -n "Completing registration... "
	fmod_status="$(curl -s "https://www.fmod.com/api-registration" \
		-H "Referer: ${completion_url}" \
		-H "Authorization: FMOD ${completion_key}" | jq -r '.status')"
	echo "\"${fmod_status}\""

	# Save username and password to disk
	echo -n "Saving credentials... "
	echo "{\"email\":\"${email}\",\"username\":\"${username}\",\"password\":\"${password}\"}" > fmod-login.json
	echo "fmod-login.json"
fi

# Get auth token
echo -n "Logging in... "
auth_data="$(curl -s "https://www.fmod.com/api-login" \
	-X POST \
	--user "${username}:${password}" \
	-H "Content-Type: text/plain;charset=UTF-8" \
	-H "Origin: https://www.fmod.com" \
	-H "Referer: https://www.fmod.com/login" \
	-d "{}")"
auth_token="$(echo -n "${auth_data}" | jq -r '.token')"
user_id="$(echo -n "${auth_data}" | jq -r '.user')"
echo_sensitive "${user_id}"

# Get download link
echo "Requesting download..."
download_link="$(curl -s "https://www.fmod.com/api-get-download-link?path=files/fmodstudio/api/Linux/&filename=${LIBRARY_NAME}.tar.gz&user_id=${user_id}" \
	-H "Authorization: FMOD ${auth_token}" \
	-H "Referer: https://www.fmod.com/download" | jq -r '.url')"

# Download the library
curl \
	-H "Referer: https://www.fmod.com/" \
	-Lo otherlibs/${LIBRARY_NAME}.tar.gz \
	"${download_link}"

# Extract the newly downloaded release
echo -n "Extracting archive... "
cd otherlibs
rm -rf "${LIBRARY_NAME}"
tar -xzf "${LIBRARY_NAME}.tar.gz"
if [ ! -d "${LIBRARY_NAME}" ]; then
	# Some releases seem to contain an archive within the archive
	tar -xzf "${LIBRARY_NAME}.tar.gz"
fi
if [ ! -d "${LIBRARY_NAME}" ]; then
	echo "Error: Archive file did not produce API folder"
	exit 1
fi
[ -L "${SYMLINK_NAME}" -o -e "${SYMLINK_NAME}" ] && rm "${SYMLINK_NAME}"
ln -s "${LIBRARY_NAME}" "${SYMLINK_NAME}"
touch "${SYMLINK_NAME}/.timestamp"
echo "done!"