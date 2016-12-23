require 'csv'

# assumptions: 
# 1. input is a csv file with fields 'bond,type,term,yield'
# => bond is the name of the bond
# => type is either corporate or government
# => term is given in years
# => yield is given in percentages
# 2. all terms are of different values
# 3. There's at least one gov bond with a term less than all corp bonds and 
#    a gov bond with a term greater than all corp bonds for spread_to_curve

def print_spread_to_benchmark(bond, benchmark, spread)
    s = bond << ',' << benchmark << ','
    if spread.is_a? Numeric
        s << '%.2f' % spread << '%'
    else
        s << spread
    end
    puts s
end

def print_spread_to_curve(bond, spread)
    s = bond << ','
    if spread.is_a? Numeric
        s << '%.2f' % spread << '%'
    else
        s << spread
    end
    puts s
end

def prep_spread_data(csv)
    file = CSV.read(csv)
    file.shift # skip the title header
    file.sort! do |a,b| #sort entries in increasing term years
        # use regex to extract the numeric part and parse to float
        a[2] = a[2].gsub!(/[^\d+[,.]\d+]/, '').to_f if a[2].is_a? String
        b[2] = b[2].gsub!(/[^\d+[,.]\d+]/, '').to_f if b[2].is_a? String
        a[3] = a[3].gsub!(/[^\d+[,.]\d+]/, '').to_f if a[3].is_a? String
        b[3] = b[3].gsub!(/[^\d+[,.]\d+]/, '').to_f if b[3].is_a? String
        a[2] <=> b[2]
    end
    return file
end

# calculate the yield spread between a corporate bond
# and its government bond benchmark
def calc_spread_to_benchmark(csv)
    file = prep_spread_data(csv)
    
    # print title
    print_spread_to_benchmark('bond', 'benchmark','spread_to_benchmark')

    gov_lower = nil #hold government lower bound term
    corp_tmp = []
    file.each do |data|
        if data[1] == "corporate"
            corp_tmp.push data
        else # government entry
            if gov_lower.nil? and !corp_tmp.empty?
                # first entries are of type corporate (no lower bound)
                corp_tmp.each do |corp_data|
                    print_spread_to_benchmark(corp_data[0], data[0],
                        (corp_data[3] - data[3]).abs)
                end
            else # given lower bound (gov_lower) and upper bound (data)
                corp_tmp.each do |corp_data|
                    if((corp_data[2] - gov_lower[2]).abs < 
                        (corp_data[2] - data[2]).abs)
                        # closest term is lower bound
                        print_spread_to_benchmark(corp_data[0], gov_lower[0],
                            (corp_data[3] - gov_lower[3]).abs)
                    else #closest term is upper bound
                        print_spread_to_benchmark(corp_data[0], data[0],
                            (corp_data[3] - data[3]).abs)
                    end
                end
            end
            corp_tmp = []
            gov_lower = data #update lower bound
        end
    end

    if !corp_tmp.empty?
        # there's corporate entries left, meaning there's no upperbound
        # use the last lower bound as closest
        corp_tmp.each do |corp_data|
           print_spread_to_benchmark(corp_data[0], gov_lower[0],
                (corp_data[3] - gov_lower[3]).abs) 
        end
       
    end

end

# calculate the spread to the government bond curve
def calc_spread_to_curve(csv)
    file = prep_spread_data(csv)

    # print title
    print_spread_to_curve('bond', 'spread_to_curve')

    gov_lower = nil #hold government lower bound term
    corp_tmp = []
    file.each do |data|
        if data[1] == "corporate"
            corp_tmp.push data
        else # government entry
            corp_tmp.each do |corp_data|
                y = corp_data[3]
                #calculate linear interpolation yield = a*term+b
                a = ((data[3]-gov_lower[3])/(data[2]-gov_lower[2])).abs
                b = data[3] - a*data[2]
                y2 = a*corp_data[2] + b
                print_spread_to_curve(corp_data[0], (y-y2).abs)
            end
            corp_tmp = []
            gov_lower = data #update lower bound
        end
    end
end