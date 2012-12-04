module Kaleidoscope
  class ImmixCollector
    def initialize
    end

    def collect
      if compaction_required?
        compact
      else
      end
    end

    def compact
      compaction_candidates.each do |cand|
        cand.each do |obj|
          if !obj.marked? && !obj.moveable?
            obj.mark!
            push obj.children # process children
          elsif !obj.marked? && obj.moveable?
            new_obj = copy obj
            obj.forwarded!
            obj.forwarding_ptr = new_obj.ptr # forwarding pointer
            push new_obj.children # process children
          elsif obj.marked? && !obj.forwarded?
            # do nothing
          elsif obj.forwarded?
            # TODO update the reference with the address stored in
            # the forwarding pointer
          else
            # do nothing?????????????
          end
        end
      end
    end

    def collection_required?
    end

    def compaction_candidates
    end
  end
end

