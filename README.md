# Bad Behavior

This Swift executable scans your LogTen Pro X for Mac logbook, looking for any
flights that may have been contrary to FAR part 91 regulations. In particular,
it attempts to locate the following flights:

* Flights made outside of the 24-month window following a BFR.
* Flights with passengers made without the required takeoffs and landings within
  the previous 90 days (including special tailwheel requirements).
* Night flights with passengers made without the required night takeoffs and
  landings within the previous 90 days (including special tailwheel
  requirements).
* IFR flights made with fewer than six approaches and one hold in the preceding
  six months (and no IPC accomplished).

It prints to the terminal a list of such flights and the reasons they are out of
currency.

## Installation and Execution

This script is a Swift Package Manager 4.0 package. Simply run `swift run` from
the command line within the package directory to build and run the script. You
will need at least Swift 4.

## Requirements

This script is built to work with the logbook created by LogTen Pro X for macOS.
You must have that application installed and your logbook must be saved in the
normal location.

Your logbook must also conform to the following:

* You must be recording night full-stop landings for tailwheel currency as
  custom landing field #5. (Currently this is not a default field in LogTen
  Pro.)
* You must not have any value in the Solo hours field for any flights after you
  attained your first private/sport certificate. This script uses the presence
  of solo hours to determine if the flight was a student pilot solo flight.
* You must not be logging visual approaches. LogTen Pro X counts these as
  approaches for currency but the FAA does not.
* You must not be logging instrument approaches that do not have at least some
  amount of IMC after the FAF. The FAA says you cannot log approaches for which
  the final segment is done entirely in VMC.
* You must be filling out the Weight field for aircraft with a max gross
  weight greater than 12,500 pounds. You must be filling out the Engine Type
  field for turbofan aircraft. (See below for turbojet aircraft.)
* If you train in a full flight simulator, you must configure the simulator with
  type Simulator, and set your custom fields as follows:
  * Custom field #1 should be the sim type ("FFS" if it's a full flight sim).
  * Custom field #2 should be the sim aircraft type, if it simulates an aircraft
    with a required type rating.
  * Custom field #3 should be the sim aircraft category and class ("ASEL",
    "AMEL", "ASES", and "AMES" are the supported values).

## Limitations

This script has basically been written to work with my logbook, and thus has
many idiosyncracies. You will likely need to modify or extend the script to get
it to work with your logbook.

### Modifications to be made to the script

The script may need to be modified to suit your needs in the following ways:

* I use field "Custom Landing 5" to record my night full-stop landings. You will
  have to modify the `LogTenProXDatabase#eachFlight` method and change it to
  your custom field.
* I use the first three custom fields on aircraft type to record simulator
  information. See above for details.
* The script contains a mapping of LogTen Pro category/class IDs to aircraft
  categories and classes. (For example, the Airplane category is ID 502.)
  I only fly airplanes and gliders. If you fly other categories of aircraft,
  you will need to modify the `categories` and `classes` statics on the
  `CommandLineTool` class.
* The script contains a mapping of LogTenPro engine types. I only fly
  reciprocating and turbofan aircraft. If you fly turbojet aircrft, you will
  need to expand the `CommandLineTool.engineTypes` static.

### Modifications to be made to your logbook

You may need to adjust the values in your logbook in the following ways:

* LogTen Pro X has no "safety pilot" field, so there's no way to know for sure
  if the approaches that were made were done in VMC, under the hood, with a
  safety pilot; or if they were done (potentially illegally) in actual. To get
  around this, the script simply verifies that two crewmembers were onboard
  (acting as PIC/P1 and SIC/P2), and that the remarks contain the words "safety
  pilot" (since you legally must log the name of the safety pilot in the
  remarks). If those conditions are met, a flight made within the 12-month
  currency period + "grace period" counts towards IFR currency.
* Your instrument checkride must be labeled as an IPC in order to prevent it
  from being flagged as illegal.

### Limitations of the script

The script is not perfect, and will generate both false positives and false
negatives:

* The script has no way of knowing if you made an IFR flight. It "guesses" that
  by assuming that a flight is IFR if you flew at least one approach or got at
  least 0.1 of actual. If you make an illegal IFR flight "in the system", but on
  a clear day with a visual approach, the script will not catch it.
  * LogTen Pro X does have an "IFR time" field where you can record time spent
    in the system. This field could be used to fix this problem, but I don't
    record IFR time, because I have no regulatory reason to do so.
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

## Help Me!

### It says all my IFR flights were out of currency!

If you have been flying practice approaches to maintain currency, there must not
be more than a 12-month gap between such flights. If you go more than 12
calendar months without having flown practice approaches, then the only way to
regain your instrument currency is via an IPC. If you missed that window even by
a day, then all your subsequent IFR flights were illegal. Get an instructor and
complete an IPC and you'll be set for the future.

### It says all my night flights were out of currency!

So firstly, don't overlook night takeoffs. People can just figure out if they've
had three night full-stops recently and then put in the power. But remember,
night takeoffs are harder to come by, since in most of these cases you take off
during the evening and land at night.

Barring that, however, it's possible you _just_ skirted by with your night
requirements, but because of time zone issues, one of your flights isn't being
counted towards your currency. See **Limitations** above for more information.
