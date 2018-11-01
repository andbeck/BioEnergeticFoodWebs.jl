#=
Functions for the Temperature Size Rule, following Forster et al 2012 & Sentis et al 2017

The function takes 3 arguments :

- dry_mass_293 : the dry mass of the organism at 293.15 K (20 celsius degrees)
- temperature_K : the temperature in Kelvin
- TSR_type : temperature size response slopes

4 different temperature size response slopes are included, in addition to the no-response scenario.
They are called by the following keywords :

1) mean_aquatic : Mean aquatic TS response, the average TS response for aquatic Metazoa
2) mean_terestrial : Mean terrestrial TS response, the average TS response for terrestrial Metazoa
3) maximum : Maximum TS response, the strongest negative TS response
4) reverse : Reverse TS response, the strongest positive TS response

The function is called in the following way :

DM293 = 0.2 # Dry mass at 20 degrees
temperature = 273.15+30 # temperature in K
TSR_t = :mean_aquatic # mean aquatic TS slope for instance

temperature_size_rule(DM20, temperature, TSR_t)

It returns the body mass of the organisms at the given temperature according to the given TS response slope.
=#

function temperature_size_rule(parameters)

    temperature_C = parameters[:T] - 273.15

    if parameters[:TSR_type] == :no_response_WM
        if length(parameters[:bodymass]) == 1
          M = parameters[:Z].^(parameters[:trophic_rank].-1)
          parameters[:bodymass] = M
        end
    elseif parameters[:TSR_type] != :no_response_WM
        PCM = 0
        if parameters[:TSR_type] == :mean_aquatic
            PCM = -3.90-0.53*log10.(parameters[:dry_mass_293])     # PCM = Percentage change in body-mass per degrés C

        elseif parameters[:TSR_type] == :mean_terrestrial
            PCM = -1.72+0.54*log10.(parameters[:dry_mass_293])

        elseif parameters[:TSR_type] == :maximum
            PCM = -8

        elseif parameters[:TSR_type] == :reverse
            PCM = 4

        elseif parameters[:TSR_type] == :no_response_DM
            PCM = 0
        end

        convert_dfmass = 6.5
        TS_response = log.(PCM/100+1)               # Sign and magnitude of TS response
        parameters[:bodymass] = convert_dfmass.*parameters[:dry_mass_293].*exp.(TS_response.*(temperature_C-20))  # dry mass converted to fresh mass

    else error("TSR_type should be one of : mean_aquatic, mean_terrestrial, maximum, reverse, no_response_WM or no_response_DM")
    end

end