package com.example.demo;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

@RestController
public class Spider {
    @RequestMapping("/")
    public String index(HttpServletRequest request) {
    String addr = request.getHeader("X-Forwarded-For");
        if(addr == null)
            addr = request.getRemoteAddr();
        return "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<body style=\"background-color:cyan;\">\n" +
                "\n" +
                "<h1>Client IP Address</h1>\n" +
                "<p>" + addr + "</p>\n" +
                "\n" +
                "</body>\n" +
                "</html>";
    }
    @RequestMapping("/vm")
    public String vm(HttpServletRequest request) {
		Runtime runtime = Runtime.getRuntime();

		int processors = runtime.availableProcessors();
		long maxMemory = runtime.maxMemory();

		return String.format("Number of processors: %d\nMax memory: " + humanReadableByteCount(maxMemory, false) + "\n", processors);
    }
	public static String humanReadableByteCount(long bytes, boolean si) {
		int unit = si ? 1000 : 1024;
		if (bytes < unit)
			return bytes + " B";
		int exp = (int) (Math.log(bytes) / Math.log(unit));
		String pre = (si ? "kMGTPE" : "KMGTPE").charAt(exp - 1) + (si ? "" : "i");
		return String.format("%.1f %sB", bytes / Math.pow(unit, exp), pre);
	}
    @RequestMapping("/memory")
    public String memory(HttpServletRequest request) {
		System.out.println("Starting to allocate memory...");
		Runtime rt = Runtime.getRuntime();
		StringBuilder sb = new StringBuilder();
		long maxMemory = rt.maxMemory();
		long usedMemory = 0;
        try{
            while (((float) usedMemory / maxMemory) < 0.90) {
                sb.append(System.nanoTime() + sb.toString());
                usedMemory = rt.totalMemory();
            }
        } catch (OutOfMemoryError e){
        // Do nothing as we expect it to happen
        } finally{
            String msg = "Allocated more than 90% (" + humanReadableByteCount(usedMemory, false) + ") of the max allowed JVM memory size ("
                    + humanReadableByteCount(maxMemory, false) + ")\n";
            System.out.println(msg);
            return msg;
        }
    }
}
