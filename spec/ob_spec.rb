require_relative('../ob')

describe "spread to benchmark" do
    let(:sample_1) {
        "bond,benchmark,spread_to_benchmark\n" <<
        "C1,G1,1.60%\n"
    }
    let(:sample_output) {
        "bond,benchmark,spread_to_benchmark\n" <<
        "C1,G1,1.60%\n" <<
        "C2,G2,1.50%\n" <<
        "C3,G3,2.00%\n" <<
        "C4,G3,2.90%\n" <<
        "C5,G4,0.90%\n" <<
        "C6,G5,1.80%\n" <<
        "C7,G6,2.50%\n"
    }

    it 'should match the output' do
        expect { calc_spread_to_benchmark("sample_1.csv") }.
            to output(sample_1).to_stdout

        expect { calc_spread_to_benchmark("sample_input.csv") }.
            to output(sample_output).to_stdout

        expect { calc_spread_to_benchmark("sample_3.csv") }.
            to output(/C7,G5,4.80%/).to_stdout
    end

    it 'should not match the output' do
        expect { calc_spread_to_benchmark("sample_1.csv") }.
            to_not output(/C1,G1,1.62%/).to_stdout
    end
end

describe "spread_to_curve" do
    let(:sample_2) {
        "bond,spread_to_curve\n" <<
        "C1,1.22%\n" <<
        "C2,2.98%\n"
    }

    it 'should match the output' do
        expect { calc_spread_to_curve("sample_2.csv") }.
            to output(sample_2).to_stdout

        expect { calc_spread_to_curve("sample_input.csv") }.
            to output(/C1,1.43%/).to_stdout

        expect { calc_spread_to_curve("sample_input.csv") }.
            to output(/C3,2.47%/).to_stdout
    end

    it 'should not match the output' do
        expect { calc_spread_to_curve("sample_1.csv") }.
            to_not output(/C5,1.93%/).to_stdout
    end
end