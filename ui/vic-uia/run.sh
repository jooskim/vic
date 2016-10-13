#!/bin/bash

drone exec --trusted -E nightly_ui_tests_secrets.yml --yaml ./ui-tests.yml
