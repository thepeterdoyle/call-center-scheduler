
-- ref.us_state_holidays (optional)
CREATE OR REPLACE TABLE `ref.us_state_holidays` (
  state_code  STRING OPTIONS(description="USPS state code."),
  holiday_date DATE OPTIONS(description="Holiday/quiet date in the state calendar.")
)
OPTIONS(description="Optional quiet-day list by state to suppress calling on low-yield or restricted dates.");
