using LightGraphs
using GraphIO

function simulateLin(G, init_nodes)
	
	num_edges = ne(G)
	num_vertices = nv(G)
	active = init_nodes

	#generate the tresholds

	tsh = rand(num_vertices)

	#initialize weight array

	weights = ones(num_edges)

	#initialize active flag array

	active = zeros(num_vertices)

	#degree array

	deg = degree(G)


	#set weights

	for (i, e) in enumerate(edges(G))
		weights[i] = 1/deg[dst(e)]
	end

	something_happened = true

	while(something_happened)
		something_happened = false
	
		for v in vertices(G)
			
			#iterate over all inactive vertices 
			
			if active[v] == 0
				
				#calculate the sum of the weights of its neighbors
				
				sum = 0
		
				for nb in neighbors(G,v)
					sum = sum + weights[nb]
				end
		
				#if the sum ecceds the threshold, set the node active
				
				if sum > tsh[v]
					active[v] = 1
					something_happened = true
				end
			end
		end
	end
	
	return active
	
end

function simulateCasc(G, init_nodes)

	num_edges = ne(G)
	num_vertices = nv(G)
	active = init_nodes

	prob = rand(num_vertices)
	
	#vector that indicates which nodes just became active. 0 = never was active ; 1 = just became active ; 2 = already was active
	
	just_became_active = copy(init_nodes)
	
	something_happened = true
	
	while(something_happened)
		something_happened = false
		
		#iterate over all nodes that just became active
		
		for (v, state) in enumerate(just_became_active)
			if state == 1
				
				#if an active node was considered, set its state to 2 so it doesn't get considered again
				
				just_became_active[v] = 2
				
				#we iterate over all neighbors of a node that just became active
				
				for n in neighbors(G, v)
					
					#if the neighbor is not active
					
					if(active[n] == 0)
						
						#toss a coin wether he becomes active
						
						coin = rand()
						
						if coin > prob[n]
							
							#if it becomes active, set both as active and just became active
							
							active[n] = 1
							just_became_active[n] = 1
							something_happened = true
						end
					end
				end
			end			
		end
	end
	
	return active
	
end

function greedyLin(G, giveaway_number, num_sim)
	num_sim_real = 0
	num_edges = ne(G)
	num_vertices = nv(G)
	
	active = zeros(num_vertices)
	
	for i in range(1, giveaway_number)
		high_score = 0
		high_score_edge = 0
		
		for e in vertices(G)
			if(active[e] == 0)
				init_nodes = copy(active)
				init_nodes[e] = 1
				score = 0
				
				for j in range(1,num_sim)
					score = score + sum(simulateLin(G, init_nodes))
					num_sim_real = num_sim_real +1
				end
				
				if(score > high_score)
					high_score = score
					high_score_edge = e
				end
			end
		end
		
		active[high_score_edge] = 1
		
	end
	
	println("numer of simulations : ")
	println(num_sim_real)
	return active
	
end

function greedyCasc(G, giveaway_number, num_sim)
	num_sim_real = 0
	num_edges = ne(G)
	num_vertices = nv(G)
	
	active = zeros(num_vertices)
	
	for i in range(1, giveaway_number)
		high_score = 0
		high_score_edge = 0
		
		for e in vertices(G)
			if(active[e] == 0)
				init_nodes = copy(active)
				init_nodes[e] = 1
				score = 0
				
				for j in range(1,num_sim)
					score = score + sum(simulateCasc(G, init_nodes))
					num_sim_real = num_sim_real +1
				end
				
				if(score > high_score)
					high_score = score
					high_score_edge = e
				end
			end
		end
		
		active[high_score_edge] = 1
		
	end
	
	println("numer of simulations : ")
	println(num_sim_real)
	return active
	
end
					
	

G = loadgraph("/home/chris/Uni/GraphMining/avgDist/Graph/3980.edges", "facebook", EdgeListFormat())

@time res = greedyLin(G, 10, 1000)
@time res = greedyCasc(G, 10, 1000)
