#!/bin/bash
# Check for argument and show usage 
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi
final=$1
#===========================STORE OCCURENCES INTO ARRAYS==================================
# Store the rows per column into variables 
mechanics_column=$(cat "$final" | cut -f13)
domain_column=$(cat "$final" | cut -f14)

# Array placeholders to store occurence counts
declare -A mechanic_counts
declare -A domain_counts

# Read each line of column and store into variable line_mech
while IFS= read -r line_mech; do
  # Read from variable line_mech, split line by comma delimiter and store into array mechanics
  IFS=',' read -r -a mechanics <<< "$line_mech"
  for mechanic in "${mechanics[@]}"; do
    # Delete whitespaces before and after values
    cleaned_mechanic=$(echo "$mechanic" | xargs)
    # If not empty, then add array counts as per values encountered
    if [[ -n "$cleaned_mechanic" ]]; then
      ((mechanic_counts["$cleaned_mechanic"]++))
    fi
  done
done <<< "$mechanics_column"

# Read each line of column and store into variable line_dom
while IFS= read -r line_dom; do
  # Read from variable line_dom, split line by comma delimiter and store into array domains
  IFS=',' read -r -a domains <<< "$line_dom"
  for domain in "${domains[@]}"; do
    # Delete whitespaces before and after values
    cleaned_domains=$(echo "$domain" | xargs)
    # If not empty, then add array counts as per values encountered
    if [[ -n "$cleaned_domains" ]]; then
      ((domain_counts["$cleaned_domains"]++))
    fi
  done
done <<< "$domain_column"

#===========================DETERMINE HIGHEST OCCURENCES==================================
# Placeholders to determine highest occurence counts
max_mech_count=0
max_mechanic="" 
max_dom_count=0
max_domain=""

# Loop over the keys of the arrays
for mechanic in "${!mechanic_counts[@]}"; do
  count_mech="${mechanic_counts[$mechanic]}"
  # Compare count to current highest. 
  # If current count is greater current highest, then update the current highest
  if [[ "$count_mech" -gt "$max_mech_count" ]]; then
    max_mech_count="$count_mech"
    max_mechanic="$mechanic"
  fi
done

# Loop over the keys of the arrays
for domain in "${!domain_counts[@]}"; do
  count_dom="${domain_counts[$domain]}"
  # Compare count to current highest. 
  # If current count is greater current highest, then update the current highest
  if [[ "$count_dom" -gt "$max_dom_count" ]]; then
    max_dom_count="$count_dom"
    max_domain="$domain"
  fi
done
#===========================PEARSON YEAR to RATING==================================
year_column=$(cut -f3 "$final")
rating_column=$(cut -f9 "$final")

# Placeholder for average/means
sum_year=0
count_year=0
sum_rating=0
count_rating=0

# Loop each line read from year_column. Store into variable year.
while IFS=$'\n' read -r year; do
    if [[ "$year" =~ ^[0-9]+$ ]]; then
        sum_year=$((sum_year + year))
        count_year=$((count_year + 1))
    fi
done <<< "$year_column"
means_year=$(echo "scale=6; $sum_year / $count_year" | bc)

# Loop each line read from rating_column. Store into variable rating.
while IFS=$'\n' read -r rating; do
    if [[ "$rating" =~ ^[0-9.]+$ ]]; then
        sum_rating=$(echo "$sum_rating + $rating" | bc)
        count_rating=$((count_rating + 1))
    fi
done <<< "$rating_column"
means_rating=$(echo "scale=6; $sum_rating / $count_rating" | bc)

# Placeholder for sum of differences from mean
sum_diff_year=0
sum_diff_rating=0

# Loop over year_column to calculate differences from the mean
while IFS=$'\n' read -r year; do
    if [[ "$year" =~ ^[0-9]+$ ]]; then
        diff=$(echo "$year - $means_year" | bc)
        sum_diff_year=$(echo "$sum_diff_year + $diff" | bc)
    fi
done <<< "$year_column"

# Loop over rating_column to calculate differences from the mean
while IFS=$'\n' read -r rating; do
    if [[ "$rating" =~ ^[0-9.]+$ ]]; then
        diff=$(echo "$rating - $means_rating" | bc)
        sum_diff_rating=$(echo "$sum_diff_rating + $diff" | bc)
    fi
done <<< "$rating_column"

# Calculate Pearson correlation
declare -a years
declare -a ratings
while IFS= read -r yline && IFS= read -r rline <&3; do
    years+=("$yline")
    ratings+=("$rline")
done <<< "$year_column" 3<<< "$rating_column"

top=0
sum_sq_diff_year=0
sum_sq_diff_rating=0

for ((i=0; i<${#years[@]}; i++)); do
    y="${years[i]}"
    r="${ratings[i]}"

    if [[ "$y" =~ ^[0-9]+$ && "$r" =~ ^[0-9.]+$ ]]; then
        diff_y=$(echo "$y - $means_year" | bc -l)
        diff_r=$(echo "$r - $means_rating" | bc -l)
        
        prod=$(echo "$diff_y * $diff_r" | bc -l)
        top=$(echo "$top + $prod" | bc -l)

        sq_diff_y=$(echo "$diff_y * $diff_y" | bc -l)
        sum_sq_diff_year=$(echo "$sum_sq_diff_year + $sq_diff_y" | bc -l)

        sq_diff_r=$(echo "$diff_r * $diff_r" | bc -l)
        sum_sq_diff_rating=$(echo "$sum_sq_diff_rating + $sq_diff_r" | bc -l)
    fi
done

# Calculating Pearson correlation between year and rating 
sqrt_year=$(echo "scale=10; sqrt($sum_sq_diff_year)" | bc -l)
sqrt_rating=$(echo "scale=10; sqrt($sum_sq_diff_rating)" | bc -l)
bottom=$(echo "$sqrt_year * $sqrt_rating" | bc -l)
pearson=$(echo "scale=6; $top / $bottom" | bc -l)

sqrt_year=$(echo "scale=10; sqrt($sum_sq_diff_year)" | bc -l)
sqrt_rating=$(echo "scale=10; sqrt($sum_sq_diff_rating)" | bc -l)
bottom=$(echo "$sqrt_year * $sqrt_rating" | bc -l)

# Check for division by zero for Pearson Year vs. Rating ###
if [[ "$bottom" == "0" || -z "$bottom" ]]; then
    pearson=0  # If denominator is zero, set correlation to 0
else
    pearson=$(echo "scale=6; $top / $bottom" | bc -l)
fi

#===========================PEARSON COMPLEXITY to RATING==================================
complexity_column=$(cut -f11 "$final")

# Placeholder for average/means
sum_complex=0
count_complex=0
sum_rating2=0
count_rating2=0

# Loop each line read from complexity_column
while IFS=$'\n' read -r complex; do
    if [[ "$complex" =~ ^[0-9.]+$ ]]; then
        sum_complex=$(echo "$sum_complex + $complex" | bc)
        count_complex=$((count_complex + 1))
    fi
done <<< "$complexity_column"
means_complex=$(echo "scale=6; $sum_complex / $count_complex" | bc)

# Loop each line read from rating_column
while IFS=$'\n' read -r rating2; do
    if [[ "$rating2" =~ ^[0-9.]+$ ]]; then
        sum_rating2=$(echo "$sum_rating2 + $rating2" | bc)
        count_rating2=$((count_rating2 + 1))
    fi
done <<< "$rating_column"
means_rating2=$(echo "scale=6; $sum_rating2 / $count_rating2" | bc)

# Calculate Pearson for complexity
declare -a complexities
declare -a ratings2

while IFS= read -r xline && IFS= read -r zline <&3; do
    complexities+=("$xline")
    ratings2+=("$zline")
done <<< "$complexity_column" 3<<< "$rating_column"

top_comp=0
sum_sq_diff_complex=0
sum_sq_diff_rating2=0

for ((i=0; i<${#complexities[@]}; i++)); do
    x="${complexities[i]}"
    z="${ratings2[i]}"

    if [[ "$x" =~ ^[0-9.]+$ && "$z" =~ ^[0-9.]+$ ]]; then
        diff_x=$(echo "$x - $means_complex" | bc -l)
        diff_z=$(echo "$z - $means_rating2" | bc -l)
        
        prod_comp=$(echo "$diff_x * $diff_z" | bc -l)
        top_comp=$(echo "$top_comp + $prod_comp" | bc -l)

        sq_diff_x=$(echo "$diff_x * $diff_x" | bc -l)
        sum_sq_diff_complex=$(echo "$sum_sq_diff_complex + $sq_diff_x" | bc -l)

        sq_diff_z=$(echo "$diff_z * $diff_z" | bc -l)
        sum_sq_diff_rating2=$(echo "$sum_sq_diff_rating2 + $sq_diff_z" | bc -l)
    fi
done

sqrt_complex=$(echo "scale=10; sqrt($sum_sq_diff_complex)" | bc -l)
sqrt_rating2=$(echo "scale=10; sqrt($sum_sq_diff_rating2)" | bc -l)
bottom_comp=$(echo "$sqrt_complex * $sqrt_rating2" | bc -l)
pearson2=$(echo "scale=6; $top_comp / $bottom_comp" | bc -l)

# Calculating Pearson correlation between complexity and rating
sqrt_complex=$(echo "scale=10; sqrt($sum_sq_diff_complex)" | bc -l)
sqrt_rating2=$(echo "scale=10; sqrt($sum_sq_diff_rating2)" | bc -l)
bottom_comp=$(echo "$sqrt_complex * $sqrt_rating2" | bc -l)

# Check for division by zero for Pearson Complexity vs. Rating
if [[ "$bottom_comp" == "0" || -z "$bottom_comp" ]]; then
    pearson2=0  # If denominator is zero, set correlation to 0
else
    pearson2=$(echo "scale=6; $top_comp / $bottom_comp" | bc -l)
fi


#===========================OUTPUT==================================
echo "The most popular game mechanics is $max_mechanic found in $max_mech_count games."
echo "The most game domain is $max_domain found in $max_dom_count games."
printf "The correlation between the year of publication and the average rating is %.3f\n" "$pearson"
printf "The correlation between the complexity of a game and its average rating is %.3f\n" "$pearson2"
