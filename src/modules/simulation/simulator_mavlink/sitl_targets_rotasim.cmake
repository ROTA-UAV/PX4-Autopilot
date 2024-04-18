if(ENABLE_LOCKSTEP_SCHEDULER STREQUAL "no")
    # find corresponding airframes
    file(GLOB rotasim_airframes
        RELATIVE ${PX4_SOURCE_DIR}/ROMFS/px4fmu_common/init.d-posix/airframes
        ${PX4_SOURCE_DIR}/ROMFS/px4fmu_common/init.d-posix/airframes/*_rotasim_*
    )

    # remove any .post files
    foreach(rotasim_airframe IN LISTS rotasim_airframes)
        if(rotasim_airframe MATCHES ".post")
            list(REMOVE_ITEM rotasim_airframes ${rotasim_airframe})
        endif()
    endforeach()
    list(REMOVE_DUPLICATES rotasim_airframes)

    # default rotasim target
    add_custom_target(rotasim
        COMMAND ${PX4_SOURCE_DIR}/Tools/simulation/rotasim/sitl_run.sh $<TARGET_FILE:px4> "rascal" ${PX4_SOURCE_DIR} ${PX4_BINARY_DIR}
        WORKING_DIRECTORY ${SITL_WORKING_DIR}
        USES_TERMINAL
        DEPENDS px4
    )

    foreach(model ${models})

        # match model to airframe
        set(airframe_model_only)
        set(airframe_sys_autostart)
        set(rotasim_airframe_found)
        foreach(rotasim_airframe IN LISTS rotasim_airframes)

            string(REGEX REPLACE ".*_rotasim_" "" airframe_model_only ${rotasim_airframe})
            string(REGEX REPLACE "_rotasim_.*" "" airframe_sys_autostart ${rotasim_airframe})

            if(model STREQUAL ${airframe_model_only})
                set(rotasim_airframe_found ${rotasim_airframe})
                break()
            endif()
        endforeach()

        if(rotasim_airframe_found)
            message(STATUS "rotasim model: ${model} (${airframe_model_only}), airframe: ${rotasim_airframe_found}, SYS_AUTOSTART: ${airframe_sys_autostart}")
        else()
            message(WARNING "rotasim missing model: ${model} (${airframe_model_only}), airframe: ${rotasim_airframe_found}, SYS_AUTOSTART: ${airframe_sys_autostart}")
        endif()

        add_custom_target(rotasim_${model}
            COMMAND ${PX4_SOURCE_DIR}/Tools/simulation/rotasim/sitl_run.sh $<TARGET_FILE:px4> ${model} ${PX4_SOURCE_DIR} ${PX4_BINARY_DIR}
            WORKING_DIRECTORY ${SITL_WORKING_DIR}
            USES_TERMINAL
            DEPENDS px4
        )
    endforeach()
endif()
