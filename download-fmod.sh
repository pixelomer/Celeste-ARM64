#!/usr/bin/env bash

set -e

if [ -d "otherlibs/fmodstudioapi20202linux" ]; then
	echo "FMOD libraries are already available."
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

printf() {
	builtin printf -- "${@}"
}

mkdir -p otherlibs

# Check if an account was created before
if [ -f "fmod-login.json" ]; then
	# Load existing account credentials from disk
	printf "Loading credentials from disk... "
	username="$(jq -r '.username' < "fmod-login.json")"
	password="$(jq -r '.password' < "fmod-login.json")"
	email="$(jq -r '.email' < "fmod-login.json")"
	echo "${email}"
else
	# Create temporary email
	printf "Creating temporary email... "
	email="$(curl -s 'https://www.1secmail.com/api/v1/?action=genRandomMailbox' | cut -d'"' -f 2)"
	password="$(dd if=/dev/urandom bs=1 count=30 2>/dev/null | base64 | sed 's/[\/+]//g')"
	username="${email%@*}"
	domain="${email:$((${#username}+1))}"
	echo "${email}"

	# Send sign up request
	printf "Creating fmod.com account... "
	register_data="\"{ \\\"username\\\":\\\"${username}\\\", \\\"password\\\":\\\"${password}\\\", \\\"company\\\":\\\"\\\", \\\"email\\\":\\\"${username}%40${domain}\\\", \\\"name\\\":\\\"${username}\\\", \\\"ml_news\\\":false, \\\"ml_release\\\":false, \\\"industry\\\":1 }\""
	curl -s \
		-X POST \
		-H 'Referer: https://www.fmod.com/profile/register' \
		-H 'Content-Type: text/plain;charset=UTF-8' \
		-H 'Origin: https://www.fmod.com' \
		-d "${register_data}" \
		'https://www.fmod.com/api-register'
	echo ""

	# Keep checking for new mails until the registration mail arrives
	printf "Waiting for registration email... "
	while true; do
		mail_id="$(curl -s "https://www.1secmail.com/api/v1/?action=getMessages&login=${username}&domain=${domain}" | jq -r ".[0].id")"
		if [ "${mail_id}" = "null" ]; then
			sleep 3
		else
			break
		fi
	done
	echo "${mail_id}"

	# Get the registration key
	printf "Getting registration key... "
	completion_url="$(curl -s "https://www.1secmail.com/api/v1/?action=readMessage&login=${username}&domain=${domain}&id=${mail_id}" | jq -r '.body' | grep https | head -n 1)"
	completion_key="$(printf "${completion_url}" | sed 's/.*\=//g')"
	printf "${completion_key}" | head -c 8
	echo " (...truncated)"

	# Complete the registration
	printf "Completing registration... "
	fmod_status="$(curl -s "https://www.fmod.com/api-registration" \
		-H "Referer: ${completion_url}" \
		-H "Authorization: FMOD ${completion_key}" | jq -r '.status')"
	echo "\"${fmod_status}\""

	# Save username and password to disk
	printf "Saving credentials... "
	echo "{\"email\":\"${email}\",\"username\":\"${username}\",\"password\":\"${password}\"}" > fmod-login.json
	echo "fmod-login.json"
fi

# Get auth token
printf "Logging in... "
basic_auth="$(printf "${username}:${password}" | base64)"
auth_data="$(curl -s "https://www.fmod.com/api-login" \
	-X POST \
	-H "Authorization: Basic ${basic_auth}" \
	-H "Content-Type: text/plain;charset=UTF-8" \
	-H "Origin: https://www.fmod.com" \
	-H "Referer: https://www.fmod.com/login" \
	-d "{}")"
auth_token="$(printf "${auth_data}" | jq -r '.token')"
user_id="$(printf "${auth_data}" | jq -r '.user')"
echo "${user_id}"

# Get download link
echo "Requesting download..."
download_link="$(curl -s "https://www.fmod.com/api-get-download-link?path=files/fmodstudio/api/Linux/&filename=fmodstudioapi20202linux.tar.gz&user_id=${user_id}" \
	-H "Authorization: FMOD ${auth_token}" \
	-H "Referer: https://www.fmod.com/download" | jq -r '.url')"

# Download the library
curl \
	-H "Referer: https://www.fmod.com/" \
	-Lo otherlibs/fmodstudioapi20202linux.tar.gz \
	"${download_link}"

# Finally.
printf "Extracting archive... "
cd otherlibs
rm -rf fmodstudioapi20202linux
tar -xzf fmodstudioapi20202linux.tar.gz
echo "done!"