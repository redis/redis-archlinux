# Map Arch compiler/linker flags to Bloom and TimeSeries's readies variables.
# Keep upstream optimization settings without patching upstream Makefiles.
ifndef _REDIS_ARCH_MODULE_FLAGS_LOADED
_REDIS_ARCH_MODULE_FLAGS_LOADED := 1

# MAKEFILES reaches recursive make, including TimeSeries's readies dependency builds.
ifneq ($(filter %/modules/redisbloom/src %/modules/redistimeseries/src \
    %/modules/redistimeseries/src/build/LibMR \
    %/modules/redistimeseries/src/build/hiredis \
    %/modules/redistimeseries/src/build/dragonbox,$(CURDIR)),)
CC_FLAGS.common += $(CPPFLAGS)
# Retain upstream -O3 while importing distribution compiler flags.
CC_C_FLAGS.lang += $(filter-out -O%,$(CFLAGS))
CC_CXX_FLAGS.lang += $(filter-out -O%,$(CXXFLAGS))
# These custom C rules omit CC_C_FLAGS.
ifneq ($(filter %/modules/redisbloom/src %/modules/redistimeseries/src/build/hiredis,$(CURDIR)),)
CC_FLAGS += $(filter-out -O%,$(CFLAGS))
endif
LD_FLAGS += $(LDFLAGS)
endif

endif
