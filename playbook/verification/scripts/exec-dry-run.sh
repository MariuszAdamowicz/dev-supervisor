#!/usr/bin/env bash
set -euo pipefail

ENTRYPOINT="${1:-new_project}"
SPEC_FILE="${2:-playbook/runtime/playbook-exec.yaml}"
INPUT_FILE="${3:-}"

ruby - "$ENTRYPOINT" "$SPEC_FILE" "$INPUT_FILE" <<'RUBY'
require "json"
require "yaml"
require "time"
require "securerandom"

entrypoint = ARGV[0]
spec_file = ARGV[1]
input_file = ARGV[2]

unless File.exist?(spec_file)
  warn "ERROR missing spec file: #{spec_file}"
  exit 2
end

spec = YAML.safe_load(File.read(spec_file), aliases: true)
entry = spec.dig("entrypoints", entrypoint)
if entry.nil?
  warn "ERROR entrypoint not found: #{entrypoint}"
  exit 2
end

external_input = {}
if input_file && !input_file.empty?
  unless File.exist?(input_file)
    warn "ERROR input file not found: #{input_file}"
    exit 2
  end
  external_input = JSON.parse(File.read(input_file))
end

session = {
  "new_project" => {
    "form" => {
      "project_name" => external_input.dig("new_project", "project_name") || "DS",
      "project_root_path" => external_input.dig("new_project", "project_root_path") || "/tmp/ds",
      "stack" => external_input.dig("new_project", "stack") || "macos-swiftui",
      "architecture" => external_input.dig("new_project", "architecture") || "modular-monolith",
      "language" => external_input.dig("new_project", "language") || "pl",
      "execution_style" => external_input.dig("new_project", "execution_style") || "iterative-tdd",
      "storage" => external_input.dig("new_project", "storage") || "file-ai"
    },
    "project_description" => external_input.dig("new_project", "project_description") || "System DS prowadzi operatora deterministycznie po krokach OP.",
    "baseline_gate_decision" => external_input.dig("new_project", "baseline_gate_decision") || {
      "decision" => "approve",
      "reason" => "baseline kompletny"
    },
    "extracted_terms" => external_input.dig("new_project", "extracted_terms") || "# Glossary\n\n- OP: Obiekt Procesu\n- GateDecision: jawna decyzja operatora\n- ProcessEvent: audit event"
  },
  "add_idea" => {
    "form" => {
      "idea_title" => external_input.dig("add_idea", "idea_title") || "Zbudowac aplikacje do zarzadzania developmentem projektow",
      "idea_description" => external_input.dig("add_idea", "idea_description") || "DS prowadzi caly lifecycle bez gubienia krokow"
    },
    "gate_decision" => external_input.dig("add_idea", "gate_decision") || {
      "decision" => "approve",
      "reason" => "idea gotowa do konwersji"
    }
  }
}

runtime = {
  "op_states" => {},
  "events" => 0,
  "gates" => 0
}

def deep_copy(obj)
  JSON.parse(JSON.generate(obj))
end

def resolve_refs(obj, session)
  case obj
  when Hash
    out = {}
    obj.each { |k, v| out[k] = resolve_refs(v, session) }
    out
  when Array
    obj.map { |x| resolve_refs(x, session) }
  when String
    if obj.end_with?("_ref")
      obj
    elsif obj.start_with?("session.")
      path = obj.split(".")
      path = path[1..] if path.first == "session"
      cur = session
      path.each do |p|
        if cur.is_a?(Hash) && cur.key?(p)
          cur = cur[p]
        else
          return obj
        end
      end
      cur
    else
      obj
    end
  else
    obj
  end
end

def session_get(session, ref)
  return ref unless ref.is_a?(String) && ref.start_with?("session.")
  path = ref.split(".")
  path = path[1..] if path.first == "session"
  cur = session
  path.each do |p|
    if cur.is_a?(Hash) && cur.key?(p)
      cur = cur[p]
    else
      return ref
    end
  end
  cur
end

def session_set(session, ref, value)
  return unless ref.is_a?(String) && ref.start_with?("session.")
  path = ref.split(".")
  path = path[1..] if path.first == "session"
  cur = session
  path[0...-1].each do |p|
    cur[p] ||= {}
    cur = cur[p]
  end
  cur[path[-1]] = value
end

def session_has?(session, ref)
  return false unless ref.is_a?(String) && ref.start_with?("session.")
  path = ref.split(".")
  path = path[1..] if path.first == "session"
  cur = session
  path.each do |p|
    return false unless cur.is_a?(Hash) && cur.key?(p)
    cur = cur[p]
  end
  true
end

def simulate(tool, action, input, session, runtime)
  now = Time.now.utc.iso8601
  case tool
  when "operator-ui"
    values =
      case input["prompt_id"]
      when "new_project_form" then session.dig("new_project", "form")
      when "project_description" then { "project_description" => session.dig("new_project", "project_description") }
      when "project_baseline_gate" then session.dig("new_project", "baseline_gate_decision")
      when "add_idea_form" then session.dig("add_idea", "form")
      when "idea_convert_gate" then session.dig("add_idea", "gate_decision")
      else { "next_action" => "continue" }
      end
    {
      "status" => "ok",
      "prompt_id" => input["prompt_id"],
      "answered_at" => now,
      "values" => values,
      "actor" => "operator:simulated"
    }
  when "storage-adapter"
    storage_action = input["action"] || action
    runtime["events"] += 1
    response = {
      "status" => "ok",
      "storage_version" => "v1",
      "event_id" => format("evt-%04d", runtime["events"])
    }

    if storage_action == "create_op_instance"
      op_id = input["op_id"] || input["op_id_template"]&.gsub("<generated_id>", "001")
      state = input.dig("payload", "state") || "created"
      runtime["op_states"][op_id] = state if op_id
      response["op_id"] = op_id if op_id
      response["op_version"] = 1 if op_id
      session["add_idea"]["idea_op_id"] = op_id if op_id&.start_with?("idea.")
    end

    transition = input["transition"]
    if transition
      op_id = input["op_id"] || session_get(session, input["op_id_ref"]) || "unknown-op"
      runtime["op_states"][op_id] = transition["to_state"]
    end

    if storage_action == "apply_gate_transition"
      gate = input["gate_decision_ref"].is_a?(Hash) ? input["gate_decision_ref"] : session.dig("new_project", "baseline_gate_decision")
      decision = gate["decision"] || "approve"
      to_state = input.dig("transition_map", decision)
      op_id = input["op_id"] || session_get(session, input["op_id_ref"]) || "unknown-op"
      runtime["op_states"][op_id] = to_state if to_state
      runtime["gates"] += 1
      response["gate_decision_id"] = format("gate-%04d", runtime["gates"])
    end

    if storage_action == "conditional_transition"
      op_id = input["op_id"] || session_get(session, input["op_id_ref"]) || "unknown-op"
      cond = input.dig("condition", "current_state_equals")
      if runtime["op_states"][op_id] == cond
        runtime["op_states"][op_id] = input.dig("transition", "to_state")
      end
    end

    response
  when "ai-runner"
    {
      "status" => "completed",
      "job_id" => "job-#{SecureRandom.hex(4)}",
      "output_ref" => "ai-output:#{action}",
      "tokens_in" => 320,
      "tokens_out" => 180
    }
  when "quality-runner"
    {
      "status" => "ok",
      "build_status" => "pass",
      "test_status" => "pass",
      "lint_status" => "pass",
      "report_ref" => "quality:bootstrap"
    }
  when "github-adapter"
    repo_name = input["repository_name"] || input["repository_name_ref"] || "ds"
    {
      "status" => "ok",
      "repository_id" => "ghrepo-#{SecureRandom.hex(3)}",
      "remote_url" => "git@github.com:simulated/#{repo_name}.git"
    }
  when "git"
    {
      "status" => "ok",
      "branch" => "feat/simulated",
      "commit_hash" => "simulated"
    }
  else
    { "status" => "ok", "note" => "no-op tool simulation" }
  end
end

puts "SIMULATION_MODE=dry-run"
puts "ENTRYPOINT=#{entrypoint}"
puts "SPEC_FILE=#{spec_file}"
puts "NO_WRITES=true"
puts "---"

steps = entry.fetch("steps")
steps.each_with_index do |step, idx|
  tool = step.fetch("tool")
  action = step.fetch("action")
  req = deep_copy(step.fetch("input"))
  req_resolved = resolve_refs(req, session)

  resp = simulate(tool, action, req_resolved, session, runtime)

  puts "STEP #{idx + 1}/#{steps.length} #{step.fetch("step_id")}"
  puts "TOOL=#{tool}"
  puts "ACTION=#{action}"
  puts "REQUEST=#{JSON.pretty_generate(req_resolved)}"
  puts "RESPONSE=#{JSON.pretty_generate(resp)}"
  if step["success_output"]
    so = step["success_output"]
    if so["data_ref"]
      unless session_has?(session, so["data_ref"])
        val =
          if tool == "operator-ui"
            resp["values"]
          elsif tool == "ai-runner"
            resp["output_ref"] || resp
          elsif tool == "github-adapter"
            resp["remote_url"] || resp
          else
            resp
          end
        session_set(session, so["data_ref"], val)
      end
    end
    if so["op_ref"] && resp["op_id"]
      session_set(session, so["op_ref"], resp["op_id"])
    end
    if so["op_state_ref"]
      op_id = req_resolved["op_id"] || req_resolved["op_id_ref"]
      session_set(session, so["op_state_ref"], runtime["op_states"][op_id]) if op_id
    end
    puts "SUCCESS_OUTPUT=#{JSON.pretty_generate(step['success_output'])}"
  end
  puts "STATE_DELTA=#{JSON.pretty_generate('op_states' => runtime['op_states'])}"
  puts "---"
end

puts "FINAL_RUNTIME_STATE=#{JSON.pretty_generate(runtime)}"
puts "TERMINAL_UI_STATE=#{entry['terminal_ui_state']}"
RUBY
