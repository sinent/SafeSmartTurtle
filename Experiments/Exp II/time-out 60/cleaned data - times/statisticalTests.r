
print("Starting..")
setwd("/Users/sinent/Desktop/src/Exp II - results/time-out 60/cleaned data - times")

apply_shapiro_wilk_test <- function(z3_intersection_data, z3_count_data, erlang_intersection_data, erlang_count) {
    
    # GridSize, number of agents and PathLength are the same for all data. So we calculate that once for all.
    # Of course, we picked the numbers ourselves and they are not following normal distribution.
    print(shapiro.test(z3_count_data$GridSize))
    print(shapiro.test(z3_count_data$NumberOfAgents))
    print(shapiro.test(z3_count_data$PathLength))

    print(shapiro.test(z3_intersection_data$Time_Average))
    print(shapiro.test(z3_count_data$Time_Average))
    print(shapiro.test(erlang_intersection_data$Time_Average))
    print(shapiro.test(erlang_count$Time_Average))
}

apply_all_correlation_tests <-function(z3_intersection_data, z3_count_data, erlang_intersection_data, erlang_count) {
    print("z3-count results:")
    apply_correlation_test(z3_count_data)
    print("z3-intersection results:")
    apply_correlation_test(z3_intersection_data)
    print("erlang-count results:")
    apply_correlation_test(erlang_count)
    print("erlang-intersection results:")
    apply_correlation_test(erlang_intersection_data)
}

apply_correlation_test <-function(data){
    t <- cor.test(data$PathLength,    data$Time_Average, method = "spearman", exact=FALSE)
    print(t)
    t <- cor.test(data$NumberOfAgents,data$Time_Average, method = "spearman", exact=FALSE)
    print(t)
    t <- cor.test(data$GridSize,      data$Time_Average, method = "spearman", exact=FALSE)
    print(t)
    t <- cor.test(data$Constraint,    data$Time_Average, method = "spearman", exact=FALSE)
    print(t) 
}

z3_count_data <- read.csv("z3_count.csv")
z3_intersection_data <- read.csv("z3_intersection.csv")
erlang_count_data <- read.csv("erlang_count.csv")
erlang_intersection_data <- read.csv("erlang_intersection.csv")

# apply_shapiro_wilk_test(z3_intersection_data,z3_count_data,erlang_intersection_data,erlang_count_data)
apply_all_correlation_tests(z3_intersection_data,z3_count_data,erlang_intersection_data,erlang_count_data)


# get the results for 15<=path<=20 and 15<=numberOfAagents<=20
# v_z3_count_space = c()
# v_erlang_count_space = c()

# print(z3_count_data[1,6])

# print(length(z3_count_data$PathLength))
# for (i in 1:length(z3_count_data$PathLength)){
#     if( (z3_count_data[i,4]>10) && (z3_count_data[i,5]>10)){
#         # print('yes')
#         v_z3_count_space<-append(v_z3_count_space,z3_count_data[i,6])
#         v_erlang_count_space<-append(v_erlang_count_space,erlang_count_data[i,6])
#     }
# }

# # print(v_z3_count_space)
# # print(v_erlang_count_space)
# wilcox.test(v_z3_count_space, v_erlang_count_space, paired = TRUE, alternative = "greater", , exact = FALSE)


