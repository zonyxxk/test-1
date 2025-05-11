#!/bin/bash
if [ $# -ne 1 ]
then
echo "usage: $0 file"
exit 1
fi

echo "************OSS1-Project1************"
echo "*        StudentID : 12222837       *"
echo "*        Name : Jonghyeok Lee       *"
echo "*************************************"

file=$1

while true; do
echo ""
echo "[MENU]"
echo "1. Search player stats by name in MLB data"
echo "2. List top 5 players by SLG value"
echo "3. Analyze the team stats - average age and total home runs"
echo "4. Compare players in different age groups"
echo "5. Search the players who meet specific statistical conditions"
echo "6. Generate a performance report (formatted data)"
echo "7. Quit"
read -p "Enter your COMMAND (1~7) : " cmd

case $cmd in
1)
echo ""
read -p "Enter a player name to search: " player
echo "Player stats for \"$player\":"
awk -F',' -v player="$player" '$2==player {printf "Player: %s, Team: %s, Age: %d, WAR: %.1f, HR: %d, BA: %.3f\n", $2, $4, $3, $6, $14, $20}' "$file"
;;

2)
echo ""
read -p "Do you want to see the top 5 players by SLG? (y/n): " yn
if [ $yn = "y" ]; then
echo ""
echo "***Top 5 Players by SLG***"
awk -F',' -v player="$player" '$2==player {print "Player: "$2", Team: "$4", Age: "$3", WAR: "$6", HR: "$14", BA: " $20}' "$file"
fi
;;

3)
read -p "Enter team abbreviation (e.g., NYY,LAD,BOS):" team
echo ""
echo "Team stats for "$team":"
awk -F',' -v team="$team" '$4==team {sum += $3; count++} END {print "Average age: ",sum/count}' "$file"
awk -F',' -v team="$team" '$4==team {sum += $14;} END {print "Total home runs: ",sum}' "$file"
awk -F',' -v team="$team" '$4==team {sum += $15;} END {print "Total RBI: ",sum}' "$file"
;;
4)
echo ""
echo "Compare players by age groups:"
echo "1. Group A(Age < 25)"
echo "2. Group B(Age 25-30)"
echo "3. Group C(Age > 30)"
read -p "Select age group (1~3): " group
echo ""
case $group in
1)
echo "Top 5 by SLG in Group A (Age < 25):"
awk -F',' 'NR>1 && $8>=502 && $3<25' "$file" | sort -t, -k22,22nr | awk -F',' '{print $2"(Team: "$4") - SLG: "$22", BA: "$20", HR: "$14}' | head -n 5
;;
2)
echo "Top 5 by SLG in Group B (Age 25-30):"
awk -F',' 'NR>1 && $8>=502 && $3>=25 && $3<=30' "$file" | sort -t, -k22,22nr | awk -F',' '{print $2"(Team: "$4") - SLG: "$22", BA: "$20", HR: "$14}' | head -n 5
;;
3)
echo "Top 5 by SLG in Group C (Age > 30):"
awk -F',' 'NR>1 && $8>=502 && $3>30' "$file" | sort -t, -k22,22nr | awk -F',' '{print $2"(Team: "$4") - SLG: "$22", BA: "$20", HR: "$14}' | head -n 5
;;
esac
;;
5)
echo ""
echo "Find players with specific criteria"
read -p "Minimum home runs: " hr
read -p "Minimum batting average (e.g., 0.280): " ba
echo""
echo "Players with HR >= "$hr" and BA >= "$ba":" 
awk -F',' -v hr="$hr" -v ba="$ba" 'NR>1 && $14>=hr && $20>=ba' "$file" | sort -t, -k14,14nr | awk -F',' '{print $2"(Team: "$4") - HR: "$14", BA: "$20", RBI: "$15", SLG: "$22}'
;;
6)
echo ""
echo "Generate a formatted player report for which team?"
read -p "Enter team abbreviation (e.g., NYY,LAD,BOS): " team
echo ""
echo "================== $team PLAYER REPORT =================="
echo "Date: $(date +"%Y/%m/%d")"
echo "---------------------------------------------------------------"
printf "%-25s %5s %7s %7s %7s %7s\n" "PLAYER" "HR" "RBI" "AVG" "OBP" "OPS"
echo "---------------------------------------------------------------"

awk -F',' -v team="$team" 'NR > 1 && $4 == team' "$file" | sort -t, -k14,14nr | awk -F',' '{count++; printf "%-25s %5s %7s %7s %7s %7s\n", $2, $14, $15, $20, $21, $23} END {print "---------------------------------------------------------------"; print "Team Totals: " count " players"}'
;;
7)
echo "Have a good day!"
exit 0
;;
esac

done
