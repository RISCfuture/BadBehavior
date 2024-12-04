# Bad Behavior

This Swift executable scans your LogTen for Mac logbook, looking for any flights
that may have been contrary to FAR part 91 regulations. In particular, it
attempts to locate the following flights:

* Flights made outside of the 24-month window following a BFR.
* Flights with passengers made without the required takeoffs and landings within
  the previous 90 days (including special tailwheel requirements).
* Night flights with passengers made without the required night takeoffs and
  landings within the previous 90 days (including special tailwheel
  requirements).
* IFR flights made with fewer than six approaches and one hold in the preceding
  six months (and no IPC accomplished).
* Flights in type-rated aircraft without the required FAR 61.58 check having
  been completed.

It prints to the terminal a list of such flights and the reasons they are out of
currency.

## Installation and Execution

This script is a Swift Package Manager 6.0 package. Simply run `swift run` from
the command line within the package directory to build and run the script. You
will need at least Swift 6.

## Assumptions and Idiosyncrasies

This script has been tailored to my specific logbook. It will likely require at
least a little modification before it works with your logbook, but it should
take you 95% of the way there. In particular:

### LogTen Pro: Flights

- LogTen Pro does not have a "night full-stop landings" field by default. You
  will need a "Custom Landings" field named "Night Full Stops". (If you are not
  recording night full-stop landings, then how are you tracking night currency?)
- LogTen Pro does not have a "checkride" Boolean field. You will need a
  "Custom Notes" field named "Checkride". Flights with any non-empty value in
  this field will be considered checkrides.
- LogTen Pro does not have a field for indicating FAR 61.58 recurrent flights.
  You will need a "Custom Notes" field named "FAR 61.58". Flights with any
  non-empty value in this field will be considered recurrent checkrides.
- LogTen Pro does not have a field for indicating FAR 61.31(k) NVG proficiency
  check flights. You will need a "Custom Notes" field named "FAR 61.31(k)".
  Flights with any non-empty value in this field will be considered NVG
  proficiency check flights.
- LogTen Pro does not have a "safety pilot" or "examiner" role. You must have
  "Custom Role" fields titled "Safety Pilot" and "Examiner".

### LogTen Pro: Aircraft and aircraft types

- This script will not work if you have modified or rearranged your engine
  types, aircraft categories, or aircraft classes.
- LogTen Pro only has "jet" and "turbofan" engine types. The "jet" type is
  assumed to mean "turbojet".
- The "aircraft type" field in my logbook does not conform to FAA aircraft
  types. For example, I have "C-172SP" as a type instead of "C172". I use a
  custom Aircraft Type field called "Type Code". If you also have such a field,
  it will use the value from that field; otherwise, it will use the normal
  aircraft type.
- This script requires more simulator information than LogTen Pro is set up for
  by default. To provide this info, you will need to modify Aircraft Type to
  include:
  - a custom field called "Sim Type" whose values can be "BATD", "AATD", "FTD",
    or "FFS" (or blank for aircraft);
  - a custom field called "Type Code" whose value is the type code for the
    aircraft being simulated (FFS and FTD only); and
  - a custom field called "Sim A/C Cat" whose value is the category and class
    for the aircraft being simulated (FTD and FFS only, values can be "ASEL",
    "ASES", "AMEL", "AMES", or "GL" for glider).

### Logging

* You must not have any value in the Solo hours field for any flights after you
  attained your first private/sport certificate. This script uses the presence
  of solo hours to determine if the flight was a student pilot solo flight.
* You must not be logging approaches if you were not the pilot flying or the
  CFI.
* You must not be logging instrument approaches that do not have at least some
  amount of IMC after the FAF. The FAA says you cannot log approaches for which
  the final segment is done entirely in VMC.
* You must be filling out the Weight field for aircraft with a max gross
  weight greater than 12,500 pounds. You must be filling out the Engine Type
  field for turbofan aircraft. (See below for turbojet aircraft.)
* Your instrument checkride must be labeled as an IPC in order to prevent it
  from being flagged as illegal.

## Limitations

The script is not perfect, and will generate both false positives and false
negatives:

* The script has no way of knowing if you made an IFR flight. It "guesses" that
  by assuming that a flight is IFR if you flew at least one approach or got at
  least 0.1 of actual. If you make an illegal IFR flight "in the system", but on
  a clear day with a visual approach, the script will not catch it.
  * LogTen does have an "IFR time" field where you can record time spent in the
    system. This field could be used to fix this problem, but I don't record IFR
    time, because I have no regulatory reason to do so.
* If you failed a private or sport pilot checkride, the script will claim you
  flew without a BFR. This is because the checkride attempt does not count as
  dual received, is not a flight review, and does not earn you solo hours, and
  therefore cannot otherwise be distinguished from a student pilot illegally
  exercising the privileges of a certificated pilot.
* Calculations are done in Zulu (UTC) time. So, for example, when checking
  passenger currency, flights up to the beginning of the UTC day 90 days prior
  are checked. The law is unclear about which time zone should be used for
  determining this 90-day window, especially if the night portion of the flight
  being checked crossed multiple time zones.
* It will mark flights as non-compliant if a flight consists of multiple legs
  logged as one flight, and one of the legs brings you into compliance. For
  example, if you do your three takeoffs and landings solo, then go pick up
  passengers for the next leg, logging both legs as a single flight, it will
  mark that flight as non-compliant.
* Instrument currency as defined in 61.57(c) requires six approaches, a hold,
  and "intercepting and tracking courses". There is no way to log that last
  part, but since it can be reasonably assumed that any instrument flight 
  involving approaches or holds by definition involves intercepting and tracking
  courses, it's simply assumed to always be true.
* The NVG currency checks only validate whether NVG takeoffs and landings are
  legal. They do not check NVG hover operations or other NVG operations that
  LogTen Pro is not set up to record.

## Help Me!

### It says all my IFR flights were out of currency!

If you have been flying practice approaches to maintain currency, there must not
be more than a 12-month gap between such flights. If you go more than 12
calendar months without having flown practice approaches, then the only way to
regain your instrument currency is via an IPC. If you missed that window even by
a day, then all your subsequent IFR flights were illegal, even if you did 6
approaches and a hold. Get an instructor and complete an IPC and you'll be set
for the future.

### It says all my night flights were out of currency!

So firstly, don't overlook night takeoffs. People can just figure out if they've
had three night full-stops recently and then put in the power. But remember,
night takeoffs are harder to come by, since in most of these cases you take off
during the evening and land at night.

Barring that, however, it's possible you _just_ skirted by with your night
requirements, but because of time zone issues, one of your flights isn't being
counted towards your currency. See **Limitations** above for more information.
