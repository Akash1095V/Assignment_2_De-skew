# Compile RTL + TB with coverage
vlog -sv +cover=bcestf deskew.sv tb_deskew.sv 

# Start simulation with coverage
vsim -gui -coverage -assertdebug -voptargs=+acc -onfinish stop work.tb_deskew

# Load waveform script
#do De-skew

# Run simulation
run -all
# Save coverage database
coverage save -assert -directive -cvg -codeAll cov.ucdb

# Generate HTML coverage report
vcover report -html -output covhtmlreport \
    -details -assert -directive -cvg \
    -code bcefst -threshL 50 -threshH 90 cov.ucdb

# (Optional) open report in browser
exec firefox covhtmlreport/index.html &

