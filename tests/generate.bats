#!/usr/bin/env bats
load '/usr/local/lib/bats/load.bash'

setup() {
  TEST_TEMP_DIR="$(temp_make)"
}

@test "generate - required variables only" {
  cp ${BATS_TEST_DIRNAME}/fixtures/expected.required.module.tf.json ${TEST_TEMP_DIR}/expected.json

  run ./main.variant module \
    --component ${TEST_TEMP_DIR}/components/preview \
    --module_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --module_name pr-1
  assert_success

  assert_file_exist ${TEST_TEMP_DIR}/components/preview/pr-1.tf.json
  run diff ${TEST_TEMP_DIR}/components/preview/pr-1.tf.json ${TEST_TEMP_DIR}/expected.json
  assert_output ""
  assert_success
}

@test "generate - all variables" {
  cp ${BATS_TEST_DIRNAME}/fixtures/expected.all.module.tf.json ${TEST_TEMP_DIR}/expected.json

  run ./main.variant module \
    --component ${TEST_TEMP_DIR}/components/preview \
    --module_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --module_name pr-1 \
    --module_attributes '{"enabled": "true", "name": "test", "namespace": "test-namespace", "stage": "test-stage"}'
  assert_success

  assert_file_exist ${TEST_TEMP_DIR}/components/preview/pr-1.tf.json
  run diff ${TEST_TEMP_DIR}/components/preview/pr-1.tf.json ${TEST_TEMP_DIR}/expected.json
  assert_output ""
  assert_success
}

@test "generate - stack yaml" {
  cp ${BATS_TEST_DIRNAME}/fixtures/expected.stack.yaml ${TEST_TEMP_DIR}/expected.stack.yaml

  run ./main.variant stack \
    --stacks_dir ${TEST_TEMP_DIR}/components/preview \
    --stack_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --stack thicc-stacks \
    --components '{"example_component": { "some_setting": "value" }}' \
    --global_vars '{"stage": "env_example"}' \
    --imports '["some/baseline"]'
  assert_success

  assert_file_exist ${TEST_TEMP_DIR}/components/preview/thicc-stacks.yaml
  run diff ${TEST_TEMP_DIR}/components/preview/thicc-stacks.yaml ${TEST_TEMP_DIR}/expected.stack.yaml
  assert_output ""
  assert_success
}

@test "generate - stack will ignore module args and vice versa" {
  run ./main.variant stack \
    --stacks_dir ${TEST_TEMP_DIR}/components/preview \
    --stack_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --stack thicc-stacks \
    --component ${TEST_TEMP_DIR}/components/preview \
    --module_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --module_name pr-1 \
    --module_attributes '{"enabled: }' \
    --components '{"example_component": { "some_setting": "value" }}' \
    --global_vars '{"stage": "env_example"}' \
    --imports '["some/baseline"]'
  assert_success
  run ./main.variant module \
    --stacks_dir ${TEST_TEMP_DIR}/components/preview \
    --stack_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --stack thicc-stacks \
    --component ${TEST_TEMP_DIR}/components/preview \
    --module_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --module_name pr-1 \
    --module_attributes '{"enabled": "blah"}' \
    --components '{"example_component": { "some_setting": "value" }}' \
    --global_vars '{"stage: env_example}' \
    --imports '["some/baseline"]'
  assert_success
}

@test "generate - non json module attribures" {
  run ./main.variant module \
    --component ${TEST_TEMP_DIR}/components/preview \
    --module_source git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 \
    --module_name pr-1 \
    --module_attributes '{"enabled: }'
  assert_failure
  assert_output --partial "with opt.module_attributes as \"{\\\"enabled: }\""
}


teardown() {
  temp_del "$TEST_TEMP_DIR"
}
