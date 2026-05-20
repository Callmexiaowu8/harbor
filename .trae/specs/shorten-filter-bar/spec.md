# Shorten Popover Filter Bar Spec

## Why
The popover page header contains many elements (title, status indicator, filter field, theme toggle, add button, refresh button, quit button), making the layout feel crowded. Reducing the filter bar width will improve visual balance and provide better spacing between elements.

## What Changes
- Reduce the Filter TextField width from 100 points to approximately 67 points (2/3 of original)
- Maintain all existing functionality and styling of the filter component
- Ensure visual consistency with surrounding elements

## Impact
- Affected specs: None (isolated UI adjustment)
- Affected code: `Sources/harbor/Views/MainView.swift` (header section, line 117)

## ADDED Requirements
### Requirement: Compact Filter Bar
The system SHALL display a compact filter input field in the popover header that occupies approximately 2/3 of its previous width.

#### Scenario: Reduced Filter Width
- **WHEN** the popover header renders
- **THEN** the Filter TextField SHALL have a width of approximately 67 points (reduced from 100 points)
- **AND** the filter functionality SHALL remain unchanged
- **AND** the visual styling (padding, background, border) SHALL remain consistent

## MODIFIED Requirements
### Requirement: Header Layout Optimization
The header HStack SHALL maintain proper spacing and alignment with the reduced filter bar width, ensuring no overlap with adjacent buttons (theme, add, refresh, quit).

#### Scenario: Balanced Header Layout
- **WHEN** the header renders with the shortened filter bar
- **THEN** all header elements SHALL be properly spaced without overflow
- **AND** the overall header appearance SHALL look balanced and less crowded

## REMOVED Requirements
None
