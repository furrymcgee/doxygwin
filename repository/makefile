# This makefile builds cygwin packages from debian source
# The debian package names are defined phony targets in a template
# It uses cygport.sh to generate a cygport files
# The cygport files inherit dpkg.cygclass
# The make process is simulated with make --dry-run
# Additional information is printed with make --trace 

.DEFAULT_GOAL = .DEFAULT

# Get a list f debian binary packages
debian/Packages:
	wget -O- -c \
	http://deb.debian.org/debian/dists/sid/main/binary-amd64/Packages.gz | \
	gunzip > $@

# Get a list of debian source packages
debian/Sources:
	wget -O- -c \
	http://deb.debian.org/debian/dists/sid/main/source/Sources.gz | \
	gunzip > $@

# Source description is downloaded with debian packages
.PRECIOUS: %.dsc

# Some %.cygport are customised to the build process
.PRECIOUS: %.cygport

.DEFAULT:
	# Notice: This makefile requires MAKECMDGOALS set to debian package name

# Create %.cygport files from debian data
%.cygport: debian/Packages debian/Sources
	mkdir $(@D) && \
	grep-dctrl -r -n -s Package -F Package ^$(notdir $(basename $@))$$ $< | \
	xargs -t sh cygport.sh > $@ || { rm $@ && exit 1 ; }

# Grep debian package name, version and architecture
define CYGPORT =
$(foreach cygport, $(shell \
	cat debian/Packages* | \
	sed /^Package:\ $1$$/,/^$$/\!d | \
	sed -z s/\\x0a\\x0a/\\x00/g | \
	sed -z /Extra-Source/d | \
	sed s/\\x00/\\x0a\\x0a/ | \
	grep ^Package:\\\|^Version:\\\|^Architecture: | \
	sed /^Version:\ /aRELEASE=1 | \
	sed '1h;1d;5~4x;$$G' | \
	sed '1h;1d;5~4x;$$G' | \
	sed '1h;1d;5~4x;$$G' | \
	sed '1~4h;4~4G' | \
	sed \
		-e 1~5s/amd64\\\|any/x86/ \
		-e 5~5s/amd64\\\|any/i686/ \
		-e s/Package:\ /NAME=/p \
		-e s/Version:\ /VERSION=/ \
		-e /^Architecture:\ /s/all/noarch/ \
		-e s/Architecture:\ /ARCHITECTURE=/ \
		| \
	tr =: \\\t\\\t | \
	paste - - - - - - | \
	cut -f2,4,6,8,10,12 | \
	sed \
		-e s@^@Y%3a%2f/@ \
		-e s@\\\t@/release/@ \
		-e s@\\\t@/@ \
		-e s@\\\t@_@ \
		-e s@\\\t@_@ \
		-e s@\\\t@.@ \
	),
	$(eval $(call TEMPLATE,$(cygport)))
)
endef

# Define rule with prerequisites
define TEMPLATE =

#.INTERMEDIATE: $1
.PHONY: $(word 1, $(subst _, , $(notdir $1)))

# Download package files
%_$(word 2, $(subst _, ,$1)).dsc: %.cygport
	cygport --32 $$< download

# Build package with cygport
%_$(word 2, $(subst _, ,$1))_$(word 3, $(subst _, ,$1)): %.cygport
	cygport --32 $$< all
	rename --verbose $(subst _,-,$1) $1 $(subst _,-,$1)

$(word 1, $(subst _, , $(notdir $1))): $(word 1, $(subst _, ,$1))_$(word 2, $(subst _, ,$1)).dsc $1
	cat $$< | grep ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH | \
	cut -d= -f2 | paste - - - - | xargs -r -L3 printf \
	$$(dir $(subst \,\\\,$1))%s_%s_%s.%s\\\n | xargs -r $(MAKE) 
	mv -v $1/dist/$$@/*.* $(dir $1) && \
	rm -rf $1

endef

# Call cygport foreach MAKECMDGOALS
ifeq (0,${MAKELEVEL})
$(foreach package, $(MAKECMDGOALS), $(eval $(call CYGPORT,$(package))))
endif

