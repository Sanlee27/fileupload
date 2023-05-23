<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>    
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "vo.*" %>
<%
	// 주소값
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir);
	
	int max = 10 * 1024 * 1024;
	
	// request 객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑 request >> mreq(멀티파트~)
	MultipartRequest mreq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());

	//유효성검사
	if(mreq.getParameter("boardNo") == null || mreq.getParameter("boardNo").equals(null)
		|| mreq.getParameter("boardFileNo") == null || mreq.getParameter("boardFileNo").equals(null)){
			response.sendRedirect(request.getContextPath()+"/boardList.jsp");
			return;
	}

	System.out.println(mreq.getParameter("boardNo") + " : removeBoardAction req boardNo");
	System.out.println(mreq.getParameter("boardFileNo") + " : removeBoardAction req boardFileNo");
	
	// 변수
	int boardNo = Integer.parseInt(mreq.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mreq.getParameter("boardFileNo"));
	
	System.out.println(boardNo + " : removeBoardAction boardNo");
	System.out.println(boardFileNo + " : removeBoardAction boardFileNo");
	
	//DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 삭제_upload폴더 내 파일
	String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no = ?";
	PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
	saveFilenameStmt.setInt(1, boardFileNo);
	
	System.out.println(saveFilenameStmt + " : removeBoardAction saveFilenameStmt");
	
	ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
	
	// __쿼리실행시 파일 경로 확인 및 삭제
	String preSaveFilename = "";
	if(saveFilenameRs.next()){
		preSaveFilename = saveFilenameRs.getString("save_filename");
	}
	File f = new File(dir+"/"+preSaveFilename);
	if(f.exists()){
		f.delete();
	} 
	
	// 삭제_목록에서
	String delSql = "DELETE FROM board WHERE board_no = ?";
	PreparedStatement delStmt =conn.prepareStatement(delSql);
	
	System.out.println(delStmt + " : removeBoardAction delStmt");
	
	delStmt.setInt(1, boardNo);
	
	int delRow = delStmt.executeUpdate();
	
	if(delRow == 1){
		System.out.println("삭제성공");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	} else {
		System.out.println("삭제실패");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);
	}
%>
