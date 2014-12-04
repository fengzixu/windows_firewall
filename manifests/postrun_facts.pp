class windows_firewall::postrun_facts (
    $enabled = false,
){
    if $enabled == true {
        exec { 'update_facts':
            command => "\"${::env_windows_installdir}\\bin\\puppet.bat\" facts upload",
            provider => windows,
            refreshonly => true,
        }
    }
}