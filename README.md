# GShare Branch Predictor Simulation

## 1. Problem Statement

Modern processors lose performance when they encounter branch instructions because the processor must decide whether to continue with the next sequential instruction or jump to another address. If this decision is made incorrectly, the pipeline wastes cycles and has to recover.

This project simulates a **dynamic branch prediction system** using the **GShare** algorithm to study how a processor can use past branch behavior to make better predictions and reduce mispredictions.

## 2. Your Idea

The idea was to build a small Verilog model that behaves like the control part of a processor.

The system:

* predicts whether a branch will be taken or not taken
* keeps track of recent branch outcomes using a Global History Register (GHR)
* uses a Branch History Table (BHT) with 2-bit saturating counters
* updates the prediction state after every branch
* redirects the Program Counter (PC) when a prediction is wrong

The key concept used is **GShare**, where the PC bits are XORed with the global history to choose the BHT entry. This helps the predictor learn from both the branch address and the recent branch pattern.

## 3. Implementation

The project is written in **Verilog HDL** and is split into the following modules.

### `p1.v` — `gshare_predictor`

This is the main prediction module.

It contains:

* a **BHT** with 8 entries
* a **GHR** with 3 bits
* 2-bit saturating counters for each BHT entry

Prediction is generated using:

* `index = PC[HISTORY_BITS+1:2] XOR GHR`
* the MSB of the selected 2-bit counter decides the prediction

On every update:

* the selected BHT counter is incremented or decremented based on `actual_taken`
* the GHR shifts in the latest branch result

A debug task `print_bht` is included to display the current BHT state during simulation.

### `p2.v` — `pc_logic`

This module updates the Program Counter.

Behavior:

* on reset, PC becomes `0`
* if a misprediction occurs, PC jumps to `correct_pc`
* if prediction is taken, PC goes to `branch_target`
* otherwise, PC increments by `4`

### `p3.v` — `branch_control`

This module compares the predicted outcome with the actual outcome.

It produces:

* `mispredict` when prediction and actual result are different
* `flush`, which is the same as the mispredict signal

### `p4.v` — `pipeline_top`

This is the top-level integration module.

It connects:

* the predictor
* branch control logic
* PC update logic

For demonstration, the branch outcome is generated synthetically using:

* `actual_taken = pc[2]`

The branch target is set as:

* `branch_target = pc + 16`

The project continuously updates the predictor so that the simulation shows how the BHT and GHR evolve over time.

### `p_tb.v` — Testbench

The testbench:

* generates the clock
* applies reset
* runs the simulation for a few cycles
* prints the PC, prediction, actual outcome, misprediction, and GHR
* prints the BHT contents after each cycle

## 4. Challenges Faced

* **Correct indexing (PC ⊕ GHR):** Small mistakes led to wrong BHT access and poor predictions. This was important because the entire GShare predictor depends on choosing the correct table entry.
* **Misprediction handling:** Ensuring correct PC update and flush logic was tricky. When the prediction was wrong, the system had to recover cleanly without breaking the execution flow.
* **GHR synchronization:** Keeping history consistent between prediction and update stages was necessary so that the predictor learned from the correct past outcomes.
* **Aliasing (index variation):** Frequent index changes slowed learning. Since multiple branch patterns can map to the same BHT entry, the predictor sometimes took time to stabilize.
* **Debugging outputs:** Interpreting PC, GHR, and BHT behavior during simulation required careful observation because the predictor state changes over time.

## 5. Results

The simulation demonstrates that:

* the predictor generates branch predictions correctly
* the BHT changes as branch outcomes are observed
* the GHR updates after every branch
* mispredictions are detected and the PC is corrected
* repeated execution shows the predictor adapting over time

The results show that a GShare-based predictor can learn branch patterns better than a static always-taken or always-not-taken approach.

## 6. Deliverables

### Code Explanation

* `p1.v`: GShare predictor with BHT and GHR
* `p2.v`: PC update logic
* `p3.v`: misprediction detection logic
* `p4.v`: top-level pipeline integration
* `p_tb.v`: simulation testbench and debug output

### Commands to Run

Using Icarus Verilog:

```bash
git clone https://github.com/tarun-227/coa_project.git
cd coa_project
iverilog -o sim p1.v p2.v p3.v p4.v p_tb.v
vvp sim
```

If you want to view waveforms, you can add dumping support in the testbench and open the generated VCD file in GTKWave.

## 7. Future Work

* **Replace the synthetic branch pattern with real instruction traces**
  This would make the simulation more realistic because real programs have branch behavior that is more complex than a simple PC-based pattern.

* **Increase the BHT size and history length**
  A larger table and longer history can reduce aliasing and improve prediction accuracy for more complicated branch patterns.

* **Add a Branch Target Buffer (BTB)**
  At present, only the branch direction is predicted. A BTB would also predict the target address, making the design closer to a real processor.

* **Simulate a deeper pipeline with realistic control hazards**
  This would help measure the actual cost of mispredictions in terms of stalls and flushes.

* **Measure prediction accuracy over a larger number of cycles**
  Quantitative metrics such as accuracy percentage and misprediction rate would make the evaluation more rigorous.

* **Display waveform traces for easier debugging and analysis**
  Waveform tools such as GTKWave make it easier to understand signal changes over time and debug hardware behavior.
