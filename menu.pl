% The predicate laptop_profile can be added or removed at run time so dynamic predicate 
% is added to both the laptop_profile as well as laptop_status

:- dynamic laptop_status/2.
:- discontiguous laptop_status/2.
:- dynamic laptop_profile/2.

% Define the maximum charge level for the battery profiles
% Conservation profile charges the laptop till 60 percent
% Optimal profile charges the laptop till 80 percent
% Full profile charges the laptop till 100 percent

battery_profile(conservation, 60).
battery_profile(optimal, 80).
battery_profile(full, 100).

% Setting the initial charge level of the laptop 
initial_charge(laptop1, 70).
initial_charge(laptop2, 95).
initial_charge(laptop3, 40).

% Define the LED colors for each battery profile
% Helps to recognize the profile set by seeing the LED color in the charger

led_color(conservation, yellow).
led_color(optimal, purple).
led_color(full, green).

% Check if a laptop needs to be charged or discharged based on the battery profile

needs_charging(Laptop, ChargeLevel, _, Profile) :-
    battery_profile(Profile, MaxThreshold),
    ChargeLevel < MaxThreshold,
    laptop_status(Laptop, Status),
    Status \= charging.

needs_discharging(Laptop, ChargeLevel, _, Profile) :-
    battery_profile(Profile, MaxThreshold),
    ChargeLevel > MaxThreshold,
    laptop_status(Laptop, Status),
    Status \= discharging.

% Update the laptop status based on the charging or discharging action
update_status(Laptop, charge, charging) :-
    retract(laptop_status(Laptop, _)),
    assert(laptop_status(Laptop, charging)).

update_status(Laptop, discharge, discharging) :-
    retract(laptop_status(Laptop, _)),
    assert(laptop_status(Laptop, discharging)).

% Charge or discharge a laptop based on the current charge level and battery profile
charge_laptop(Laptop, ChargeLevel, Time, Profile) :-
    needs_charging(Laptop, ChargeLevel, Time, Profile),
    update_status(Laptop, charge, _),
    format("Charging ~w at ~w% for ~w minutes~n", [Laptop, ChargeLevel, Time]).

discharge_laptop(Laptop, ChargeLevel, Time, Profile) :-
    needs_discharging(Laptop, ChargeLevel, Time, Profile),
    update_status(Laptop, discharge, _),
    format("Discharging ~w at ~w% for ~w minutes~n", [Laptop, ChargeLevel, Time]).

% Prompting the user to choose a battery profile based on their use case

suggest_profile(_, UseCase, Profile) :-
    memberchk(UseCase-Profile, [
        coding-optimal,
        gaming-conservation,
        productivity-optimal,
        future-full
    ]),
    format("Suggested ~w profile for the Use case : ~w~n", [Profile, UseCase]),
    led_color(Profile, LedColor),
    format("LED color: ~w~n", [LedColor]).

% Set the battery profile for a laptop
set_profile(Laptop, Profile) :-
    battery_profile(Profile, _),
    retractall(laptop_profile(Laptop, _)),
    assert(laptop_profile(Laptop, Profile)),
    format("Battery profile set to ~w for ~w~n", [Profile, Laptop]).

% Get the current status of a laptop
get_status(Laptop, Status) :-
    laptop_status(Laptop, Status).

laptop_status(laptop1, discharging).
laptop_status(laptop2, charging).
laptop_status(laptop3, discharging).

% Prints the current status of a laptop
print_status(Laptop) :-
    get_status(Laptop, Status),
    atom_string(StatusString, Status),
    atom_concat('The laptop is currently ', StatusString, Message),
    writeln(Message).

% Laptop_Status has multiple definitions so to mitigate discontiguous is used

:- discontiguous laptop_status/2.

:- initialization main.

main :- runbatteryplus.

runbatteryplus :- 
    writeln(""),
    writeln(" Welcome to the smart laptop charging system menu "),
    writeln("Select an option:"),
    writeln("1. Set battery profile for a laptop"),
    writeln("2. Charge a laptop"),
    writeln("3. Discharge a laptop"),
    writeln("4. Suggest a profile"),
    writeln("5. Check if laptop is charging or discharging"),
    writeln("6. Is a charge recommended for the laptop"),
    writeln("7. Is a discharge recommended for the laptop"),
    writeln("8. Check battery percentage of laptop battery"),
    writeln("9. Check battery profile set of the laptop"),
    writeln("10. Exit"),
    read(Input),
    process_input(Input),
    (   Input = 10
    ->  true
    ;   runbatteryplus
    ).
process_input(1) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    writeln("Enter the battery profile (conservation, optimal, full):"),
    read(Profile),
    set_profile(Laptop, Profile),
    main.

process_input(2) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    initial_charge(Laptop, ChargeLevel),
    suggest_profile(Laptop, coding, Profile),
    writeln("Enter the charging time (in minutes):"),
    read(Time),
    charge_laptop(Laptop, ChargeLevel, Time, Profile),
    main.

process_input(3) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    initial_charge(Laptop, ChargeLevel),
    suggest_profile(Laptop, gaming, Profile),
    writeln("Enter the discharging time (in minutes):"),
    read(Time),
    discharge_laptop(Laptop, ChargeLevel, Time, Profile),
    main.

process_input(4) :-
    writeln("List down your use case scenario to recommend a battery profile:"),
    writeln("Enter the use case such as (coding, gaming, productivity, future):"),
    read(UseCase),
    suggest_profile(_, UseCase, _),
    main.

process_input(5) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    print_status(Laptop),
    main.

process_input(6) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    initial_charge(Laptop, ChargeLevel),
    suggest_profile(Laptop, coding, Profile),
    battery_profile(Profile, MaxThreshold),
    (   ChargeLevel >= MaxThreshold
    ->  writeln("No, a charge is not recommended.")
    ;   writeln("Yes, a charge is recommended.")
    ),
    main.

process_input(7) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    initial_charge(Laptop, ChargeLevel),
    suggest_profile(Laptop, gaming, Profile),
    battery_profile(Profile, MaxThreshold),
    (   ChargeLevel =< MaxThreshold
    ->  writeln("No, a discharge is not recommended.")
    ;   writeln("Yes, a discharge is recommended.")
    ),
    main.


process_input(8) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    initial_charge(Laptop, ChargeLevel),
    format("Current charge level of ~w: ~w%~n", [Laptop, ChargeLevel]),
    main.

process_input(9) :-
    writeln("Enter the laptop name:"),
    read(Laptop),
    laptop_profile(Laptop, Profile),
    format("The battery profile is set to ~w for ~w~n", [Profile, Laptop]),
    main.

process_input(10) :-
    writeln("Goodbye"),
    halt.

process_input(_) :-
    writeln("Invalid input, please try again."),
    main.
