{ lib
, stdenv
, fetchurl
, makeWrapper
, jdk
}:

stdenv.mkDerivation rec {
  pname = "jdt-language-server";
  version = "1.7.0";
  timestamp = "202112161541";

  src = fetchurl {
    url = "https://download.eclipse.org/jdtls/milestones/${version}/jdt-language-server-${version}-${timestamp}.tar.gz";
    sha256 = "0ll5rgd8i8wfg2zz0ciapakl66qqaw344129qj72cyiixkgjh31g";
  };

  sourceRoot = ".";

  buildInputs = [
    jdk
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase =
    let
      # The application ships with config directories for linux and mac
      configDir = if stdenv.isDarwin then "config_mac" else "config_linux";
      # The application will store it's data here. Note especially the escaping so
      # that the env vars are interpreted at runtime and not during installPhase.
      runtimePath = "\\\${XDG_CACHE_HOME:-\\$HOME/.cache}/jdt-language-server";
    in
    ''
      # Copy jars
      install -D -t $out/share/java/plugins/ plugins/*.jar

      # Copy config directories for linux and mac
      install -Dm 444 -t $out/share/config ${configDir}/*

      # Get latest version of launcher jar
      # e.g. org.eclipse.equinox.launcher_1.5.800.v20200727-1323.jar
      launcher="$(ls $out/share/java/plugins/org.eclipse.equinox.launcher_* | sort -V | tail -n1)"

      # The wrapper script will create a directory in the user's cache, copy in the config
      # files since this dir can't be read-only, and by default use this as the runtime dir.
      #
      # The following options are required as per the upstream documentation:
      #
      #   -Declipse.application=org.eclipse.jdt.ls.core.id1
      #   -Dosgi.bundles.defaultStartLevel=4
      #   -Declipse.product=org.eclipse.jdt.ls.core.product
      #   -noverify
      #   --add-modules=ALL-SYSTEM
      #   --add-opens java.base/java.util=ALL-UNNAMED
      #   --add-opens java.base/java.lang=ALL-UNNAMED
      #
      # Other options which the user may change:
      #
      #   -Dlog.level:
      #     Log level.
      #     This can be overidden by setting JAVA_OPTS.
      #   -configuration:
      #     The application will read the configuration from this directory but also needs
      #     to be able to write here (hence mode 17777).
      #     This can be overidden by specifying -configuration to the wrapper.
      #   -data:
      #     The application stores runtime data here. We set this to <cache-dir>/$PWD
      #     so that projects don't collide with each other.
      #     This can be overidden by specifying -configuration to the wrapper.
      #
      # Java options, such as -Xms and Xmx can be specified by setting JAVA_OPTS.
      makeWrapper ${jdk}/bin/java $out/bin/jdt-language-server \
        --run "mkdir -p ${runtimePath}" \
        --run "install -Dm 1777 -t ${runtimePath}/config $out/share/config/*" \
        --add-flags "-Declipse.application=org.eclipse.jdt.ls.core.id1" \
        --add-flags "-Dosgi.bundles.defaultStartLevel=4" \
        --add-flags "-Declipse.product=org.eclipse.jdt.ls.core.product" \
        --add-flags "-Dlog.level=ALL" \
        --add-flags "-noverify" \
        --add-flags "\$JAVA_OPTS" \
        --add-flags "-jar $launcher" \
        --add-flags "--add-modules=ALL-SYSTEM" \
        --add-flags "--add-opens java.base/java.util=ALL-UNNAMED" \
        --add-flags "--add-opens java.base/java.lang=ALL-UNNAMED" \
        --add-flags "-configuration \"${runtimePath}/config\"" \
        --add-flags "-data \"${runtimePath}/data\$PWD\""
    '';

  meta = with lib; {
    homepage = "https://github.com/eclipse/eclipse.jdt.ls";
    description = "Java language server";
    license = licenses.epl20;
    maintainers = with maintainers; [ matt-snider ];
  };
}
