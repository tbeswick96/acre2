/*
	Copyright � 2016,International Development & Integration Systems, LLC
	All rights reserved.
	http://www.idi-systems.com/

	For personal use only. Military or commercial use is STRICTLY
	prohibited. Redistribution or modification of source code is 
	STRICTLY prohibited.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
	POSSIBILITY OF SUCH DAMAGE.
*/
#define COMPONENT sys_io
#include "\idi\clients\acre\Addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_SYS_IO
	#define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SYS_IO
	#define DEBUG_SETTINGS DEBUG_SETTINGS_SYS_IO
#endif

#include "\idi\clients\acre\Addons\main\script_macros.hpp"

#define IO_STATE_IDL	0
#define IO_STATE_AWK	1
#define IO_STATE_RCV	2
#define IO_STATE_SND	3

#define PACKET_PREFIX   "3TA"
#define REMOTE_PACKET_PREFIX "AT3"