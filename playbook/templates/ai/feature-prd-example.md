# Feature: Routing

## Goal
Route requests to providers according to priority and failure state.

## Inputs
- request
- provider list
- provider quota state

## Outputs
- provider response
- provider selection metadata

## Rules
- fallback on provider error
- skip disabled provider
- respect configured priority
