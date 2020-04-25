.DEFAULT_GOAL = .

.PRECIOUS: %.cygport %.dsc

.INTERMEDIATE: \
	dpkg_1.19.7_1.i686 \
	sensible-utils_0.0.12_1.noarch \

NOARCH = $(addprefix noarch/release/, \
	calm \
	debconf \
	doc-base \
	sensible-utils \
	strip-nondeterminism\
)

I686 = $(addprefix x86/release/, \
	dh-exec \
	dpkg \
	publib-dev \
	recutils \
	swish++ \
)

${.DEFAULT_GOAL}: $(I686) $(NOARCH)
	$(MAKE) $^

%.cygport:
	grep-dctrl -n -s Package -F Package $(notdir $(basename $@)) Packages | \
	xargs sh cygport.sh > $@ || { rm $@ && exit 1 ; }

%.dsc:
	$(MAKE) $(word 1, $(subst _, ,$@)).cygport
	cygport --32 $(word 1, $(subst _, , $@)).cygport download

%.i686 %.noarch:
	$(MAKE) $(word 1, $(subst _, ,$@))_$(word 2, $(subst _, , $@)).dsc
	cygport --32 $(word 1, $(subst _, , $@)).cygport prep
	rename $(subst _,-,$@) $@

noarch/release/sensible-utils: sensible-utils_0.0.12_1.noarch
x86/release/dpkg: dpkg_1.19.7_1.i686
%: %.cygport
	grep -H ^NAME\\\|^VERSION\\\|RELEASE\\\|^ARCH $< | \
	cut -d= -f2 | paste - - - - | \
	xargs -L4 printf %s_%s_%s.%s\\\n | xargs $(MAKE)
	mv $@_*/dist/* $@

Sources:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/source/Sources.gz | \
	gunzip > $@

Packages:
	wget -O- -c \
	http://deb.debian.org/debian/dists/stable/main/binary-amd64/Packages.gz | \
	gunzip > $@

