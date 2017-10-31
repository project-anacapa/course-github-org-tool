/*
 * In this configuration we want to use master as a worker so we must add the submit label
 */ 

import jenkins.model.*

// NOTE: this is a good reference: https://github.com/MovingBlocks/GroovyJenkins/blob/master/src/main/groovy/AddNodeToJenkins.groovy

// TODO: change this for the production implementation, we do NOT want submit label on master
println("Jenkins configuring 'submit' label on all available workers (only for development setup)")
println("\tTODO: change this for the production implementation, we do NOT want submit label on master.")

def instance = Jenkins.getInstance()

if (!instance.getLabelString().contains("submit"))
{
    println("\tMaster node did not have 'submit' label... adding it.")
    instance.setLabelString(instance.getLabelString() + " submit")
} 
else 
    println("\tMaster node already has 'submit' label.")

instance.save()

// Jenkins.instance.nodes.each {
//     println "\tProcessing slave with name: $slave.nodeName\n"

//     if (!slave.labelString.contains("submit"))
//     {
//         slave.labelString += " " + submit
//         println "\t\tAdded 'submit' label to string. New value: $slave.labelString"     
//     }
// }

// Jenkins.instance.save()

