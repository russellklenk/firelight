package com.ninjabird.firelight.state
{
    import com.ninjabird.firelight.debug.DebugTrace;

    /**
     * Implements the interface for interacting with a finite state machine.
     */
    public final class StateMachine
    {
        /**
         * State implementations return this value when they do not change state.
         */
        public static const NO_CHANGE:int      =-1;

        /**
         * The event identifier sent to state implementations when no event is
         * being sent to the signal handler.
         */
        public static const NO_EVENT:int       =-1;

        /**
         * The signal indicating that the state is being entered.
         */
        public static const SIGNAL_ENTER:int   = 0;

        /**
         * The signal indicating that an event is being pushed to the state.
         */
        public static const SIGNAL_EVENT:int   = 1;

        /**
         * The signal indicating that the state is executing an update tick.
         */
        public static const SIGNAL_UPDATE:int  = 2;

        /**
         * The signal indicating that the state is being executed.
         */
        public static const SIGNAL_LEAVE:int   = 3;

        /**
         * An array mapping signal ID to a string name. Used for debugging.
         */
        public static const SIGNAL_NAMES:Array = [
            'SIGNAL_ENTER',
            'SIGNAL_EVENT',
            'SIGNAL_UPDATE',
            'SIGNAL_LEAVE'
        ];

        /**
         * A table where the index (key) represents a state identifier, and
         * the value represents the FSMState implementation for the current
         * state.
         */
        private var stateTable:Vector.<Function>;

        /**
         * A statically-allocated array of storage slots for queued events.
         */
        private var eventStore0:EventBuffer;

        /**
         * A statically-allocated array of storage slots for queued events.
         */
        private var eventStore1:EventBuffer;

        /**
         * The event store buffer used for read operations. This points to one
         * of the members eventStore0 or eventStore1.
         */
        private var eventStoreR:EventBuffer;

        /**
         * The event store buffer used for write operations. This points to
         * one of the members eventStore0 or eventStore1.
         */
        private var eventStoreW:EventBuffer;

        /**
         * The set of strings used to map a state ID to a string name. This
         * data is used for debugging purposes.
         */
        public var stateNames:Array;

        /**
         * The set of strings used to map an event ID to a string name. This
         * data is used for debugging purposes.
         */
        public var eventNames:Array;

        /**
         * Indicates whether to enable debug output for state signals,
         * transitions and events.
         */
        public var enableDebug:Boolean;

        /**
         * The maximum number of events ever seen in the event queue.
         */
        public var highWatermark:int;

        /**
         * The identifier of the current state. This value is used to index
         * into stateTable to retrieve the implementation for the current
         * state. Generally, this value should not be set directly.
         */
        public var currentState:int;

        /**
         * The number of times StateMachine::update() has been called.
         */
        public var updateCount:int;

        /**
         * Constructs a new state machine with no active states.
         * @param stateCount The number of states defined in the state machine.
         */
        public function StateMachine(stateCount:int)
        {
            this.stateTable    = new Vector.<Function>(stateCount, true);
            this.eventStore0   = new EventBuffer();
            this.eventStore1   = new EventBuffer();
            this.eventStoreR   = this.eventStore0;
            this.eventStoreW   = this.eventStore1;
            this.stateNames    = null;
            this.eventNames    = null;
            this.enableDebug   = false;
            this.highWatermark = 0;
            this.currentState  = 0;
            this.updateCount   = 0;
        }

        /**
         * Registers a state implementation with the state machine.
         * @param id The unique identifier of the state.
         * @param callback The object instance implementing the state logic.
         * @throws ArgumentError One or more of the parameters are invalid.
         */
        public function handle(id:int, callback:Function) : void
        {
            this.stateTable[id] = callback;
        }

        /**
         * Pushes an event onto the back of the event queue. The event is
         * dispatched to the appropriate state on the next update tick.
         * @param id The event identifier.
         * @param data Optional data associated with the event.
         * @param flush true to flush any pending events in the queue.
         */
        public function notify(id:int, data:*=null, flush:Boolean=false) : void
        {
            var buffer:EventBuffer = this.eventStoreW;
            if (flush)
            {
                buffer.flush();
            }

            buffer.push(id, data);

            if (buffer.eventCount  > this.highWatermark)
            {
                this.highWatermark = buffer.eventCount;
            }
        }

        /**
         * Implements the main state update loop for the state machine.
         * @param currentTime The current accumulated time, in seconds.
         * @param elapsedTime The duration of the previous clock tick, in seconds.
         * @param globalState Application-defined state data.
         */
        public function update(currentTime:Number) : void
        {
            var NOCHANGE:int      = StateMachine.NO_CHANGE;
            var NOEVENT:int       = StateMachine.NO_EVENT;
            var SIGEVT:int        = StateMachine.SIGNAL_EVENT;
            var SIGUPD:int        = StateMachine.SIGNAL_UPDATE;
            var SIGNALS:Array     = StateMachine.SIGNAL_NAMES;
            var STATES:Array      = this.stateNames;
            var EVENTS:Array      = this.eventNames;
            var debug:Boolean     = this.enableDebug;
            var run:Boolean       = true;
            var eventIndex:int    = 0;
            var stateId0:int      = this.currentState;
            var stateId1:int      = this.currentState;
            var handler0:Function = this.stateTable[stateId0];
            var handler1:Function = this.stateTable[stateId1];
            var rbuf:EventBuffer  = null;
            var wbuf:EventBuffer  = null;
            var evData:*          = null;
            var evId:int          = 0;

            // disable debug output if required data is not specified.
            if (debug && STATES === null) debug = false;
            if (debug && EVENTS === null) debug = false;
            if (handler0 === null)
            {
                if (debug) DebugTrace.out('FSM: No handler for state %d.', STATES[stateId0]);
                return;
            }

            // swap the read and write buffers:
            wbuf = this.eventStoreR;
            rbuf = this.eventStoreW;
            this.eventStoreR = rbuf;
            this.eventStoreW = wbuf;
            this.eventStoreW.flush();

            // on the first tick, send SIGNAL_ENTER to our initial state.
            if (this.updateCount === 0)
            {
                if (debug) DebugTrace.out('FSM: Sending SIGNAL_ENTER to state %s.', STATES[stateId0]);
                handler0(currentTime, StateMachine.SIGNAL_ENTER, NOEVENT, null, stateId0);
            }

            // send signals and process queued events
            while (run)
            {
                // by default, break after a single iteration
                run = false;

                // consume and dispatch events until the state has changed
                // or there are no events remaining in the event queue.
                while ((stateId0 === stateId1) && (eventIndex < rbuf.eventCount))
                {
                    evId   = rbuf.eventIds [eventIndex];
                    evData = rbuf.eventData[eventIndex++];

                    // the event callback potentially causes a state change.
                    if (debug) DebugTrace.out('FSM: Sending event %s to state %s.', EVENTS[evId], STATES[stateId0]);
                    stateId1 = handler0(currentTime, SIGEVT, evId, evData, stateId0);
                    if (stateId1 === NOCHANGE) stateId1 = stateId0;
                    if (stateId0 !== stateId1)
                    {
                        // a state transition has occurred.
                        handler1 = this.stateTable[stateId1];
                        if (handler1 === null)
                        {
                            if (debug) DebugTrace.out('FSM: No handler for state %s.', STATES[stateId1]);
                            return;
                        }
                        // leave the old state; enter the new state:
                        if (debug) DebugTrace.out('FSM: Changing state from %s to %s.', STATES[stateId0], STATES[stateId1]);
                        handler0(currentTime, StateMachine.SIGNAL_LEAVE, NOEVENT, null, stateId1);
                        handler1(currentTime, StateMachine.SIGNAL_ENTER, NOEVENT, null, stateId0);
                        run = true;
                    }
                }

                // swap states for the next loop iteration (no debug output).
                handler1(currentTime, SIGUPD, NOEVENT, null, stateId1);
                stateId0 = stateId1;
                handler0 = handler1;
                this.currentState = stateId1;
            }

            // we're finished with this update tick.
            this.updateCount++;
        }
    }
}
