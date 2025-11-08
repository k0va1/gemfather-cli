.PHONY: test install lint-fix install_gem remove_gem reinstall_gem start

start:
	exe/gemfather

install:
	bundle install

lint-fix:
	bundle exec standardrb --fix

test:
	@env $$(cat .env | xargs) bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

install_gem:
	yes | rm -rf pkg/*
	bundle exec rake build
	gem install --local pkg/*.gem

remove_gem:
	yes | gem uninstall gemfather

reinstall_gem: remove_gem install_gem
