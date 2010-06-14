
require 'rubygems'
#require 'rubigraph'
require 'xmlrpc/client'

require 'set'

class Ider

	def initialize
		@id_seq = 0
		@ids = {}
	end	
	
	def id_for thing
		return @ids[thing] if @ids.has_key? thing
		@id_seq += 1
		@ids[thing] = @id_seq
	end

end

# add <item,weight> pairs
# only allow N in the list
# add returns item removed if the added item bumps existing
class TopN

	def initialize max_size
		@items = []
		@max_size = max_size
		@min_weight = 1.0/0 
	end

	def recalc_min
		first_weight = @items.first[1]
		@min_weight = @items.inject(first_weight) { |a,iw| iw[1] < a ? iw[1] : a }
	end

	def ignore? weight
		@items.size == @max_size && weight <= @min_weight
	end

	def add item, weight	

		item_already_present = @items.find { |iw| iw[0] == item } 
		if item_already_present
			old_weight = item_already_present[1] 
			item_already_present[1] = weight		
			recalc_min if @min_weight == old_weight
			return :already_present
		end

		if @items.size < @max_size
			@items << [item,weight]
			@min_weight = weight if weight < @min_weight
			return :newly_added
		end

		if weight > @min_weight
			item_to_remove = @items.find { |iw| iw[1] == @min_weight }
			@items.delete item_to_remove
			@items.unshift [item,weight]
			recalc_min
			return item_to_remove[0]
		end

		raise "should have checked ignroe and not GOT here!"

	end

end

class UbiGraph

	MAX_EDGES = 10

	def initialize
		@server = XMLRPC::Client.new2("http://127.0.0.1:20738/RPC2")
		@server.call 'ubigraph.clear'

		@vertex_ids = Ider.new
		@edge_ids = Ider.new
		@top_n = TopN.new 100
	end

	def add_ub_vertex id, title
		puts "id=#{id} title=#{title}"
		@server.call "ubigraph.new_vertex_w_id", id
		@server.call "ubigraph.set_vertex_attribute", id, "label", title
		@server.call "ubigraph.set_vertex_attribute", id, "size", "0.1"
	end

	def add_ub_edge e_id, v1_id, v2_id
		@server.call "ubigraph.new_edge_w_id", e_id, v1_id, v2_id
		@server.call "ubigraph.set_edge_attribute", e_id, "arrow", "true"
	end

	def update_ub_weight_for_edge e_id, weight
		@server.call "ubigraph.set_edge_attribute", e_id, "strength", (Math.log(weight)).to_s
	end

	def remove_ub_edge e_id
		@server.call "ubigraph.remove_edge", e_id
	end

	def add_edge v1, v2, weight		
		return if @top_n.ignore? weight
		puts ">add_edge v1=#{v1} v2=#{v2} weight=#{weight}"

		v1_id = @vertex_ids.id_for v1
		v2_id = @vertex_ids.id_for v2
		e12_id = @edge_ids.id_for [v1_id,v2_id]
		puts "edge#{e12_id} for points #{v1} and #{v2}"

		add = @top_n.add e12_id, weight

		if add == :ignored
			puts ">>ignore"
			# nothing

		elsif add == :already_present
			puts ">>update already present"
			update_ub_weight_for_edge e12_id, weight

		elsif add == :newly_added
			puts ">>new!"
			add_ub_vertex v1_id, v1 # possible this to refer to an EXISTING vertex!
			add_ub_vertex v2_id, v2 # possible this to refer to an EXISTING vertex!
			add_ub_edge e12_id, v1_id, v2_id

		else
			puts ">>removing edge! #{add}"
			remove_ub_edge add
			puts ">>new!"
			add_ub_vertex v1_id, v1 # possible this to refer to an EXISTING vertex!
			add_ub_vertex v2_id, v2 # possible this to refer to an EXISTING vertex!
			add_ub_edge e12_id, v1_id, v2_id

		end

		puts ">>@top_n = #{@top_n.inspect}"
	end

end
