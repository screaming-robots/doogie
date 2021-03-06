#!/bin/bash
set -e

function set_twitter_config {
	cat <<-EOF >> src/ratpack/twitter4j.properties
	oauth.consumerKey=$TWITTER_CONSUMER_KEY
	oauth.consumerSecret=$TWITTER_CONSUMER_SECRET
	oauth.accessToken=$TWITTER_ACCESS_TOKEN
	oauth.accessTokenSecret=$TWITTER_ACCESS_TOKEN_SECRET
	EOF
}

function start_selenium {
	sudo start xvfb
	wget http://selenium.googlecode.com/files/selenium-server-standalone-2.35.0.jar --quiet
	java -jar selenium-server-standalone-2.35.0.jar > /dev/null 2>&1 &
}

function npm_install {
	for PLUGIN in $1
	do
		sudo npm install -g $PLUGIN --silent
	done

	sudo npm install --silent
}

function run_karma_tests {
	karma start src/test/js/karma.conf.js --single-run
}

function run_spock_tests {
	./gradlew test
}

function build_app {
	./gradlew buildApp
}

function run_protractor_tests {
	./build/install/doogie/bin/doogie > /dev/null 2>&1 &
	while ! curl http://localhost:5050/ &> /dev/null; do sleep 5; done
	protractor src/test/js/protractor.conf.js
}

set_twitter_config
start_selenium
npm_install "karma karma-cli protractor ngmin uglify-js"
run_karma_tests
run_spock_tests
build_app
run_protractor_tests
