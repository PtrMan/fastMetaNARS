How to compile dat thing?
===

for the dmd compiler:

(generate the sourcode for the Deriver, required to repeat after chaning the description of the deriver)

rdmd -gc fastMetaNars/codegen/GenerateRules.d

(compile the pretest for the deriver to see some output)

rdmd -gc fastMetaNars/PretestDeriver.d